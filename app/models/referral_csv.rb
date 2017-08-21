require 'csv'
class ReferralCSV
	class << self
		def read_referrals(all_referral_data)
			puts "inside the model func: read_referrals"


			referrals_hash = Hash.new

			all_referrals_file = all_referral_data.read
			CSV.parse(all_referrals_file, :quote_char => "|") do |row|
				# row_columns_array = row.parse_csv
				unless row[0] == "List Name"
					referrals_hash[row[1]] = row[12]
					# puts "first column: #{row[1]}"
					# puts "second column: #{row[12]}"
				end
      end



      referrals_hash.each do |key, value|
			  puts "#{key}: #{value}"
			  # key is referee email
			  # value is referrer code

			  # ???try to find the referee
			  referee = Trainer.where("email = ?", key).first
			  if referee.nil?
			  	puts "could not find referee with email"
			  	# could not find referee
			  	# this email is NOT associated with a trainer yet
			  else
			  	puts "foundreferee with email"
			  	# found referee
			  	# this email is associated with a trainer
			  	if referee.referrer.nil?
			  		puts "the referee does not have a referrer yet"
			  		# this referee has not been allocated a referrer yet
			  		# !!!!set the referrer
			  		# ???try to find the referrer
			  		referrer = Trainer.where("api_token LIKE :query", query: "#{value[3..-1]}%").first
			  		if referrer.nil?
			  			puts "coul not find the referrer with api characters, this will be somewhat of a problem"
			  			#could not find referrer PROBLEM

			  		else
			  			puts "found referee with email"
			  			#found referrer
			  			referee.referrer = referrer
			  			referee.save
			  		end
			  	else
			  		puts "referee already has a referrer"
			  		# this referee already has a referrer
			  		# do nothing

			  	end
			  end
			end
      
		end
	end
end