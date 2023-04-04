module Pagination
  extend ActiveSupport::Concern

  included do
  end

  def page_meta_info(total_rows, limit, current_page)
    page = 0
    total_pages = 0

    total_pages = (total_rows.to_f / limit.to_f).ceil if total_rows > 0
    page = current_page.to_i if total_rows > 0

    hash = {
      total: total_rows,
      itemsPerPage: limit,
      totalPages: total_pages,
      currentPage: page
    }

    return hash
  end

end
