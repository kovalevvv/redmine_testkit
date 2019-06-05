module TestcasesHelper
  def link_to_add_step(name, f, association)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
       render(association.to_s.singularize, f: builder)
    end
    content_tag :div, :class => 'buttons' do
      link_to(name, '#', class: "add_steps icon icon-add", data: {id: id, fields: fields.gsub("\n", "")})
    end
  end

  def make_folders_legend(folder, text="", first: true)
    if folder.parent.present?
      text = make_folders_legend(folder.parent, text, first: false)
    end
    text = text + "#{folder.name}"
    text = text + " » " unless first
    text
  end
end
