module ComfortableMexicanSofa
	module CmsAdmin
		module SitesController
			def crafty_create(path,label)
    			@site = Cms::Site.new(params[:path=>path,label => label])
	    		@site.hostname ||= request.host.downcase
	    		@site.save!
	    	end
	    end
	end
  end
end