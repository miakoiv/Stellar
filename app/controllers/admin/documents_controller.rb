#encoding: utf-8

class Admin::DocumentsController < AdminController

  include Reorderer

  # GET /admin/documents/1
  # This is only called by Dropzone as callback for success.
  def show
    @document = Document.find(params[:id])
    @documentable = @document.documentable

    respond_to do |format|
      format.js
    end
  end

  # POST /admin/documentable/1/documents
  def create
    @documentable = find_documentable
    @document = @documentable.documents.build(document_params.merge(priority: @documentable.documents.count))

    respond_to do |format|
      if @document.save
        track @document, @documentable
        format.json { render json: @document, status: 200 } # for dropzone
      else
        format.html { render json: {error: t('.error')} }
        format.json { render json: {error: @document.errors.full_messages.join(', ')}, status: 400 }
      end
    end
  end

  # DELETE /admin/documents/1
  def destroy
    @document = Document.find(params[:id])
    @documentable = @document.documentable
    track @document, @documentable

    respond_to do |format|
      if @document.destroy
        format.js
      end
    end
  end

  private
    # Finds the associated documentable by looking through params.
    # Invokes a friendly_id find if the class implements it.
    def find_documentable
      params.each do |name, value|
        if name =~ /(.+)_id$/
          klass = $1.classify.constantize
          if klass.respond_to?(:friendly)
            association_method = $1.tableize
            return current_store.send(association_method).friendly.find(value)
          else
            return klass.find(value)
          end
        end
      end
      nil
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def document_params
      params.require(:document).permit(
        :attachment
      )
    end
end
