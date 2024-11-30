module ApplicationHelper
  def markdown(text)
    return "" if text.blank?
    coderayified = CodeRayify.new(filter_html: true,
    hard_wrap: true)
    options = {
      autolink: true,
      tables: true,
      fenced_code_blocks: true,
      strikethrough: true,
      superscript: true,
      highlight: true
    }
    markdown = Redcarpet::Markdown.new(coderayified,
    options
    )

    markdown.render(text).html_safe
  end

  class CodeRayify < Redcarpet::Render::HTML
    def block_code(code, language)
      label = language ? "[#{language.upcase}]" : "[code block]"
      code_block = CodeRay.scan(code, language).div(
        line_numbers: :table,
        line_number_start: 1
      )
      "<div class='code-block-container' data-controller='code-copy'>
        <div class='flex items-center justify-between px-4 py-2 bg-gray-100 border-b'>
          <span class='text-sm text-gray-600'>#{label}</span>
          <button class='inline-flex items-center px-3 py-1 text-sm text-gray-600 bg-white rounded border 
                       hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500
                       transition-colors duration-150 ease-in-out'
                  data-action='click->code-copy#copy'
                  data-code-copy-target='button'
                  data-code='#{CGI.escape_html(code)}'>
            Copy
          </button>
        </div>
        #{code_block}
      </div>"
    end
  end
end
