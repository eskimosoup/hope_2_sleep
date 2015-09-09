module AdminTableHelper

# Commented out in preference for the method in eskimo_tables.
# If that fails delete the plugin and uncomment this to restore original functionality.
#
#  def admin_table(locals_in, render_table = 'admin/shared/admin_table', table_id = 'table')
#    defaults = {
#                :drag_handle => 'Name', 
#                :menu => true, 
#                :sorting => true, 
#                :paging => true,
#                :notes => false,
#                :edit_action => "edit",
#                :delete_action => "destroy",
#                :delete_message => "Are you sure?",
#                :show_action => nil,
#                :order_action => "order",
#                :highlight => nil,
#                :lowlight => lambda{|x| !x.display? },
#                :css_class => nil,
#                :images => false
#              }
#    columns = locals_in[:columns].map do |column|
#      if column.kind_of?(String) or column.kind_of?(Symbol)
#        column = column.to_s
#        if column.split("_").last == "id"
#          cname = column.gsub("_id", "")
#          [cname.split("_").map{|w| w.capitalize}.join(" "), lambda{|o| o.send(cname) ? o.send(cname).name : ""}, column]
#        else
#          [column.split("_").map{|w| w.capitalize}.join(" "), column, column]
#        end
#      else
#        column
#      end
#    end
#    locals = defaults.merge(locals_in).merge(:columns => columns, :table_id => table_id)
#    if locals[:list].length > 0
#      render :partial => render_table, :locals => locals
#    else
#      render :partial => "admin/shared/no_items"
#    end
#  end
    
end
