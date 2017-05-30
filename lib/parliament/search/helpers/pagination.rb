
module Parliament
  module Search
    module Helpers
      module PaginationHelper
        def current_page
          @start_page / @count + 1
        end

        def first_page
          current_page < 7 ? 1 : current_page - 5
        end

        def last_page
          if @results_total.to_i < 10 * @count
            (@results_total.to_f / @count).ceil
          elsif current_page < 7
            10
          else
            current_page + 4 < (@results_total.to_f / @count).ceil ? current_page + 4 : (@results_total.to_f / @count).ceil
          end
        end

        def page_range
          (first_page...current_page).to_a.concat((current_page..last_page).to_a)
        end

        def next_page
          current_page + 1
        end

        def previous_page
          current_page - 1
        end

        def start_page(page)
          (page - 1) * @count + 1
        end
      end
    end
  end
end
