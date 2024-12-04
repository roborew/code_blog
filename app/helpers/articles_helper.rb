module ArticlesHelper
  include Pagy::Frontend
  def pagy_nav(pagy)
    html = '<nav class="flex items-center flex-start space-x-2">'

    # Previous link
    html << if pagy.prev
      link_to("Previous", pagy_url_for(pagy, pagy.prev), class: "px-3 py-2 border text-sm font-medium text-gray-700 hover:bg-gray-100")
    else
      '<span class="px-3 py-2 border text-sm font-medium text-gray-300">Previous</span>'
    end

    # Page links
    pagy.series.each do |item|
      html << case item
      when Integer
        link_to(item, pagy_url_for(pagy, item), class: "px-3 py-2 border text-sm font-medium text-gray-700 hover:bg-gray-100")
      when String
        "<span class='px-3 py-2 border text-sm font-medium text-white bg-blue-500'>#{item}</span>"
      when :gap
        '<span class="px-3 py-2 border text-sm font-medium text-gray-500">...</span>'
      end
    end

    # Next link
    html << if pagy.next
      link_to("Next", pagy_url_for(pagy, pagy.next), class: "px-3 py-2 border text-sm font-medium text-gray-700 hover:bg-gray-100")
    else
      '<span class="px-3 py-2 border text-sm font-medium text-gray-300">Next</span>'
    end

    html << "</nav>"
    html.html_safe
  end
end
