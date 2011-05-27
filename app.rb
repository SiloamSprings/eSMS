# bring in our requires, libs, and models
# TODO: move requires to Bundler
%w[sinatra twilio rack-flash dm-core dm-validations dm-migrations dm-aggregates dm-sqlite-adapter].each { |lib| require lib }
%w[page_group contact].each { |model| require "#{Dir.pwd}/models/#{model}.rb" }
%w[config].each { |lib| require "#{Dir.pwd}/lib/#{lib}.rb" }

class EmergencySMS
  
  ######################################
  # INDEX AND MISC ROUTES
  #
   
  # display an index
  get '/' do
    @grouplist = Pagegroup.all(:order => [:id.asc])
    @contacts = Contact.all(:order => [:id.asc])

    erb :index
  end

  # admin page
  # TODO: add login_required
  get '/admin' do 
    @grouplist = Pagegroup.all(:order => [:id.asc])
    @contacts = Contact.all(:order => [:id.asc])

    erb :admin
  end

  ######################################
  # TWILIO SEND ROUTES
  #

  # show us the quicksend form
  get '/quicksend' do
    erb :quicksend
  end

  # quicksend post logic
  post '/quicksend' do
    number = params[:number]
    body = params[:body]

    response = Twilio::SMS.create(:to => number, :from => TNUM, :body => body)
    flash[:notice] = response.status

    redirect "/"
  end

  # render form for paging an entire group 
  get '/pagegroup' do
    @groups = Pagegroup.all
    erb :pagegroup
  end
  
  # send page for entire group
  post '/pagegroup' do
    body = params[:body]
    group = params[:group]

    numbers = []
    Pagegroup.get(1).contacts.each do |contact|
      numbers << contact.number
    end

    numbers.each do |num|
      response = Twilio::SMS.create(:to => num, :from => TNUM, :body => body)
    end

    flash[:notice] = response.status
    redirect "/"
  end

  # render form for paging single contacts
  get '/pagecontact' do
    @contacts = Contact.all
    erb :pagecontact
  end
  
  # send page for a single contact
  post '/pagecontact' do
    body = params[:body]
    contact = Contact.get(params[:contact])

    response = Twilio::SMS.create(:to => contact.number, :from => TNUM, :body => body)

    flash[:notice] = response.status
    redirect "/"
  end

  ######################################
  # PAGEGROUP ROUTES
  #
 
  # render the form for a new pagegroup
  get '/newgroup' do
    @contacts = Contact.all

    erb :newgroup
  end

  # save a new group
  post '/newgroup' do 
    name = params[:name]
    description = params[:description]

    pagegroup = Pagegroup.create(:name => name, :description => description)
    flash[:errors] = pagegroup.errors.full_message unless pagegroup.save

    params[:contact].each do |contact|
      addcontact = ContactPagegroup.create(
        :contact => Contact.get(contact),
        :pagegroup => pagegroup
      )

      addcontact.save
    end

    redirect "/admin"
  end

  # build the form to edit a group
  get '/editgroup/:id' do
    @group = Pagegroup.get(params[:id])
    @contacts = Contact.all
    erb :editgroup
  end

  # save an edited group
  post '/editgroup/:id' do
    name = params[:name]
    description = params[:description]
    group = Pagegroup.get(params[:id])

    # build an array of selected contacts
    selected = Array.new
    params[:contact].each {|k| selected << k.to_i}

    # build an array of associated contact ids
    assoc_id = group.contacts.all.map {|n| n.id}

    # FIXME: needs flash
    group.update(:name => name, :description => description)

    # remove contacts not included in selection
    assoc_id.each do |id0|
      ContactPagegroup.get(params[:id], id0).destroy unless selected.include?(id0)
    end

    # add contacts included in selection
    selected.each do |id1|
      unless assoc_id.include?(id1)
        ContactPagegroup.create(:pagegroup_id => params[:id], :contact_id => id1)
      end
    end

    redirect "/admin"
  end

  # delete group
  get '/delgroup/:id' do
    @group = Pagegroup.get(params[:id])
    @group.destroy unless @group.nil?
    redirect"/admin"
  end

  ######################################
  # CONTACT ROUTES
  #

  # render the form for a new contact
  get '/newcontact' do
    @groups = Pagegroup.all

    erb :newcontact
  end

  # new contact
  post '/newcontact' do
    name = params[:name]
    number = params[:number]

    # create/save a new contact
    contact = Contact.create(:name => name, :number => number)
    contact.save

    # add that contact to the specified group
    # FIXME: fix the group lookup garbage here and add
    #        some error checking
    params[:group].each do |group|
      addgroup = ContactPagegroup.create(
        :contact => contact, 
        :pagegroup => Pagegroup.get(group)
      )

      # is this step necessary?
      addgroup.save
    end

    redirect "/admin"
  end

  # build the form to edit a contact
  get '/editcontact/:id' do
    @contact = Contact.get(params[:id])
    @groups = Pagegroup.all
    erb :editcontact
  end

  # save an edited contact
  post '/editcontact/:id' do
    name = params[:name]
    number =  params[:number]
    contact = Contact.get(params[:id])
    

    # build an array of selected groups 
    selected = Array.new
    params[:group].each {|k| selected << k.to_i}

    # build an array of associated contact ids
    assoc_id = contact.pagegroups.all.map {|n| n.id}

    # FIXME: needs flash
    contact.update(:name => name, :number => number)
    
    # remove groups not included in selection
    assoc_id.each do |id0|
      ContactPagegroup.get(id0, params[:id]).destroy unless selected.include?(id0)
    end

    # add groups included in selection
    selected.each do |id1|
      unless assoc_id.include?(id1)
        ContactPagegroup.create(:pagegroup_id => id1, :contact_id => params[:id])
      end
    end

    redirect "/admin"
  end

  # delete contact 
  get '/delcontact/:id' do
    @contact = Contact.get(params[:id])
    @contact.destroy unless @contact.nil?
    redirect "/admin"
  end
end
