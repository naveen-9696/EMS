# namespace :salary_records do
#   desc "Generate salary records for previous month"

#   task generate: :environment do
#     previous_month = Date.current.prev_month

#     month = previous_month.month
#     year = previous_month.year

#     puts "Generating salary records for #{month}/#{year}"

#     Employee.find_each do |employee|
#       begin
#         result = SalaryRecords::Create.call(
#           params: {
#             employee_id: employee.employee_id,
#             month: month,
#             year: year
#           }
#         )

#         if result.success?
#           puts "Success: #{employee.employee_id}"
#         else
#           puts "Failed: #{employee.employee_id}"
#           puts result[:error] || result[:errors]
#         end

#       rescue StandardError => e
#         puts "Error: #{employee.employee_id} - #{e.message}"
#       end
#     end

#     puts "Salary generation completed!"
#   end
# end
