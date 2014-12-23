require 'rubygems'
require 'json'
require 'base64'

class ParserLog
  attr_accesor :log_bod

  def initialize(file, value, print_to_file=nil, file_to_print=nil)
    @file = file
    @value = value
    @print_to_file = print_to_file
    @file_to_print = file_to_print
    @bods_analized = Array.new
    @log_bod = Hash.new
    @count = 0
  end

  def convert_to_operations
    if value.start_with?('BATCH')
      open(file).grep(/#{value}/).each do |line|
        @count += 1
        # Inicio para un BATCH
        params_string = "{"+line.scan( /\{([^>]*)\}/).last.first+"}"

        key_hash = line.scan(/\[([^*]*?)\]/).first.first + @count.to_s

        json_params = JSON.parse(params_string)

        @log_bod[key_hash] = {operation: line.scan(/\[([^*]*?)\]/)[3].first,
                            text: line,
                            params_object: json_params
                            }

        # puts json_params["parameters"]["raw"]["bod_id"]
        # puts
        bod_id = json_params["parameters"]["raw"]["bod_id"]

        #Para cada bod de un BATCH
        unless (bod_id.start_with?('BATCH') || bods_analized.include?(bod_id))
          bods_analized << bod_id
          open(file).grep(/#{bod_id}/).each do |bod_line|
            @count += 1
            bod_related_string = "{"+bod_line.scan( /\{([^>]*)\}/).last.first+"}"
            bod_related_json = JSON.parse(bod_related_string)
            key_hash = bod_line.scan(/\[([^*]*?)\]/).first.first + @count.to_s
            @log_bod[key_hash] = {operation: bod_line.scan(/\[([^*]*?)\]/)[3].first,
                            text: bod_line,
                            params_object: bod_related_json
                            }
            #puts key_hash
            #Para los eventos generados a partir del payroll_exchange_id
            if bod_related_json["parameters"].has_key?("raw") && bod_related_json["parameters"]["raw"].has_key?("payroll_exchange_id")
              payroll_exchange_id = bod_related_json["parameters"]["raw"]["payroll_exchange_id"]
              open(file).grep(/#{payroll_exchange_id}/).each do |payroll_exchange_event_line|
                @count += 1
                payroll_exchange_event_string = "{"+payroll_exchange_event_line.scan( /\{([^>]*)\}/).last.first+"}"
                payroll_exchange_event_json = JSON.parse(payroll_exchange_event_string)
                key_hash = payroll_exchange_event_line.scan(/\[([^*]*?)\]/).first.first + @count.to_s
                @log_bod[key_hash] = {operation: payroll_exchange_event_line.scan(/\[([^*]*?)\]/)[3].first,
                            text: payroll_exchange_event_line,
                            params_object: payroll_exchange_event_json
                            }
                #puts key_hash
              end
            end
          end
        end
      end
    else
      open(file).grep(/#{value}/).each do |bod_line|
        @count += 1
        bod_related_string = "{"+bod_line.scan( /\{([^>]*)\}/).last.first+"}"
        bod_related_json = JSON.parse(bod_related_string)
        key_hash = bod_line.scan(/\[([^*]*?)\]/).first.first + @count.to_s
        @log_bod[key_hash] = {operation: bod_line.scan(/\[([^*]*?)\]/)[3].first,
                        text: bod_line,
                        params_object: bod_related_json
                        }
        #puts key_hash
        #Para los eventos generados a partir del payroll_exchange_id
        if bod_related_json["parameters"].has_key?("raw") && bod_related_json["parameters"]["raw"].has_key?("payroll_exchange_id")
          payroll_exchange_id = bod_related_json["parameters"]["raw"]["payroll_exchange_id"]
          open(file).grep(/#{payroll_exchange_id}/).each do |payroll_exchange_event_line|
            @count += 1
            payroll_exchange_event_string = "{"+payroll_exchange_event_line.scan( /\{([^>]*)\}/).last.first+"}"
            payroll_exchange_event_json = JSON.parse(payroll_exchange_event_string)
            key_hash = payroll_exchange_event_line.scan(/\[([^*]*?)\]/).first.first + @count.to_s
            @log_bod[key_hash] = {operation: payroll_exchange_event_line.scan(/\[([^*]*?)\]/)[3].first,
                        text: payroll_exchange_event_line,
                        params_object: payroll_exchange_event_json
                        }
            #puts key_hash
            #puts payroll_exchange_event_line unless payroll_exchange_event_json["parameters"]["raw"].has_key?("bod_id")
          end
        end
      end
    end
  end

  def search_confirm bod_id
    @count = 100
    @log_bod = open(@file).grep(/#{bod_id}/).inject(@log_bod) do |log_bod, confirm_line|
      @count += 1
      operation = confirm_line.scan(/\[([^*]*?)\]/)[3].first
        confirm_string = "{"+confirm_line.scan( /\{([^>]*)\}/).last.first+"}"
        confirm_json = JSON.parse(confirm_string)
        key_hash = confirm_line.scan(/\[([^*]*?)\]/).first.first + @count.to_s
        @log_bod[key_hash] = {operation: confirm_line.scan(/\[([^*]*?)\]/)[3].first,
                    text: confirm_line,
                    params_object: confirm_json
                    }
        @log_bod
    end
    @log_bod
  end



end

# attached_files_hour = log_bod.keys.sort.first[0, 15]
# open(file).grep(/#{attached_files_hour}/).each do |file_line|
#   operation = file_line.scan(/\[([^*]*?)\]/)[3].first
#   if operation == 'create_bod_msg'
#     file_string = "{"+file_line.scan( /\{([^>]*)\}/).last.first+"}"
#     file_json = JSON.parse(file_string)
#     raw_attachment = file_json["parameters"]["raw"]["bod_file"]
#     unless raw_attachment.nil?
#       decoded_attachment = Base64.decode64(raw_attachment)
#       bod_id_msg = file_json["parameters"]["raw"]["bod_id"]
#       if decoded_attachment[/#{value}/] && bod_id_msg != value
#         log_bod = search_confirm bod_id_msg, file, log_bod
#       end
#     end
#   end
# end
# log_bod.keys.each do |key|
#   puts log_bod[key]
#   puts "*" * 100
# end


# file_uniq = "#{@file_to_print}_uniq.log"


# if @print_to_file == 'true'
#   file = File.open(@file_to_print, 'w')
#   file = log_bod.keys.sort.inject(file) do |file, key|
#     file.puts log_bod[key][:text]
#     file
#   end
#   file.close
#   file = File.open(file_uniq, "w+")
#   file.puts File.readlines(@file_to_print).uniq
#   file.close
# end
