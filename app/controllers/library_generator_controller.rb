BrisaEntry; BrisaUser; BrisaModel; BrisaUserSetting; BrisaGroup; BrisaRole;

class LibraryGeneratorController < ApplicationController
  LANGUAGES = %w(javascript ruby python)

  def index
    @dispatcher = BrisaApiDispatcher.singleton
  end

  def show
    @namespace, @lang = params[:id].split(':')
    @dispatcher = BrisaApiDispatcher.singleton
    @ns = @dispatcher.ns[@namespace]
    if @ns.nil?
      render html: "#{ns} not found" and return
    elsif !LANGUAGES.include?(@lang)
      render html: "#{@lang} not supported" and return
    end
    @objs = @ns.objects.keys
    render 'show.txt.erb', content_type: 'text/plain', layout: false
  end
end
