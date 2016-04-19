class Public::IndexController < ApplicationController

  def index
    # render only layout, but make rails think we render only some file, but not layout
    render file: 'layouts/application', layout: false
  end

end