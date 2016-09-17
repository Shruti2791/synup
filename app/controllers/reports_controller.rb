class ReportsController < ApplicationController

	before_filter :load_user, only: :show
	before_filter :get_user_account_id, only: :show, if: ->{ @user.present? }

	def show
		@total_localities = get_locations
		@last_month_locations_added = locations_added_last_month
		@last_month_locations_deleted = locations_deleted_last_month
		@popular_locations = get_three_popular_states
	end

	private

		def load_user
			@user = ActiveRecord::Base.connection.execute("select 1 from users where id = #{params[:id]}").first
			not_found_response unless @user
		end

		def get_user_account_id
			@account_id = ActiveRecord::Base.connection
				.execute("select id from accounts where user_id = #{params[:id].to_i}").first["id"].to_i
		end

		def locations_added_last_month
			ActiveRecord::Base.connection
				.execute("select count(*) from locations where account_id = #{@account_id} and created_at::date > current_date - interval '1' month")
				.first["count"]
		end

		def locations_deleted_last_month
			ActiveRecord::Base.connection
				.execute("select count(*) from locations where account_id = #{@account_id} and archived_at::date > current_date - interval '1' month")
				.first["count"]
		end

		def get_locations
			ActiveRecord::Base.connection.execute("select count(*) from locations where account_id = #{@account_id}").first["count"]
		end

		def get_three_popular_states
			ActiveRecord::Base.connection.execute("select count(*) as locations_in_state, state_id, states.name from locations inner 
				join states on locations.state_id = states.id group by state_id, states.name order by count(*) desc limit 3").to_a
		end
end