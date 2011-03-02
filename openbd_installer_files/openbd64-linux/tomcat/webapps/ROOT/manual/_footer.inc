</div>
</td>
</tr>
<tr>
	<td colspan="2">
		<div id="footer">
			<p style="float:left;">&copy; Copyright <cfoutput>#Year(now())#</cfoutput> OpenBD Project   .   All Rights Reserved   .   <a href="http://www.openbluedragon.org/">Built and Powered By Open BlueDragon</a></p>
			<p style="float:right;">Except where otherwise noted, content on this site is licensed under a <a href="http://creativecommons.org/licenses/by/3.0/">Creative Commons Attribution 3.0 License</a></p>
		</div>
	</td>
</tr>
</table>

<script>
$(function () {
	$("#manual").tree({
	ui:{theme_name: "default"},
	types:{"default":{clickable:true,renameable:false,deletable:false,creatable:false,draggable:false,max_children:-1,max_depth:-1,valid_children:"all"}},
	callback:{onselect:function(NODE, TREE_OBJ){var href = $(NODE).find("a").attr("href");if ( href != null && href != "" && href != "#" ){document.location = href;}}}
	});
});
</script>

</body></html>