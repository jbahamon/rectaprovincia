extends MarginContainer


func set_item(credits_item):
	$CreditsEntry/AssetUsage.text = credits_item.asset_usage
	$CreditsEntry/AssetName.text = "\t%s ([color=light_sky_blue][url]%s[/url][/color])" % [
		credits_item.asset_name, 
		credits_item.asset_url
	]
	
	if credits_item.get("author_literal", false):
		$CreditsEntry/AuthorName.text = "\t%s" % credits_item.author_name
		
	else:
		$CreditsEntry/AuthorName.text = "\tBy %s" % credits_item.author_name
	
	if credits_item.author_url != "":
		$CreditsEntry/AuthorName.text += " ([color=light_sky_blue][url]%s[/url][/color])" % credits_item.author_url

func _on_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))
