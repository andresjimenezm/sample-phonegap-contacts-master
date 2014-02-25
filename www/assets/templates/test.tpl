<div class="node <%= node.type %>" id="node-<%= node.nid %>" data-nid="<%= node.nid %>" data-role="content" data-theme="d">
	<div class="content">
        <h2 class="title" ><%= node.title %></h2>
		<% if(node.field_image != undefined && node.field_image[0] != null){ %>	
			<div class="field-image">     
			        <img  class="field-field_image" alt="" src="<%= meta.base_root+meta.base_path+node.field_image[0].filepath %>" />
			</div>
		<% } %>
		<div class="content-content"><p><%= node.body.replace(/(\r\n|\n|\r)/gm,"<br>") %></p></div>
		<% if(node.field_iframe != undefined && node.field_iframe[0] != null){ %>	
			<div class="field-iframe"></div>
		<% } %>
	</div>
</div>