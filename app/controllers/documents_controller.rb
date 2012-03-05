class DocumentsController < ApplicationController
  # GET /documents
  # GET /documents.json
  def index
    @documents = Document.all
    @document = Document.new
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @documents }
    end
  end

  # POST /documents
  # POST /documents.json
  def create
    @document = Document.new()
    @document.process params[:document][:file]
    
    respond_to do |format|
      if @document.save
        format.html { redirect_to :action => :index , notice: 'Document was successfully created.' }
        format.json { render json: @document, status: :created, location: @document }
      else
        format.html { render action: "new" }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /documents/1
  # DELETE /documents/1.json
  def destroy
    @document = Document.find(params[:id])
    @document.destroy

    respond_to do |format|
      format.html { redirect_to documents_url }
      format.json { head :no_content }
    end
  end
  
  def share
    @document = Document.find(params[:id])

    respond_to do |format|
        format.html
        format.js {render :layout => !request.xhr?}
    end
  end
  
end
