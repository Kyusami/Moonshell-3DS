-- Set private "Photo" mode
mode = "Photo"

-- Internal module settings
master_index_p = 0
p_p = 1
update_frame = false
ui_enabled = false
not_started = true
my_photos = {}
function AddDirPhoto(dir)
	tmp = System.listDirectory(dir)
	for i,file in pairs(tmp) do
		if not file.directory then
			if string.upper(string.sub(file.name,-4)) == ".PNG" or string.upper(string.sub(file.name,-4)) == ".BMP" or string.upper(string.sub(file.name,-4)) == ".JPG" then
				table.insert(my_photos,{dir.."/"..file.name,file.name})
			end
		else
			AddDirPhoto(dir.."/"..file.name)
		end
	end
end
AddDirPhoto("/DCIM")
if #my_photos > 0 then
	x_print = 0
	y_print = 0
	big_image = false
	current_photo = Screen.loadImage(my_photos[1][1])
	width = Screen.getImageWidth(current_photo)
	height = Screen.getImageHeight(current_photo)
	if width > 400 then
		width = 400
		big_image = true
	end
	if height > 240 then
		height = 240
		big_image = true
	end
else
	ShowError("DCIM folder is empty.")
	CallMainMenu()
end

-- Module main cycle
function AppMainCycle()

	-- Clear bottom screen
	Screen.clear(BOTTOM_SCREEN)
	
	-- Update current image
	if update_frame then
		update_frame = false
		Screen.freeImage(current_photo)
		x_print = 0
		y_print = 0
		big_image = false
		current_photo = Screen.loadImage(my_photos[p_p][1])
		width = Screen.getImageWidth(current_photo)
		height = Screen.getImageHeight(current_photo)
		if width > 400 then
			width = 400
			big_image = true
		end
		if height > 240 then
			height = 240
			big_image = true
		end
	end
		
	-- Showing current image
	if big_image then
		Screen.drawPartialImage(0,0,x_print,y_print,width,height,current_photo,TOP_SCREEN)
		x,y = Controls.readCirclePad()
		if (x < - 100) and (x_print > 0) then
			x_print = x_print - 5
			if x_print < 0 then
				x_print = 0
			end
		end
		if (y > 100) and (y_print > 0) then
			y_print = y_print - 5
			if y_print < 0 then
				y_print = 0
			end
		end
		if (x > 100) and (x_print + width < Screen.getImageWidth(current_photo)) then
			x_print = x_print + 5
		end
		if (y < - 100) and (y_print + height < Screen.getImageHeight(current_photo)) then
			y_print = y_print + 5
		end
		if x_print + width > Screen.getImageWidth(current_photo) then
			x_print = Screen.getImageWidth(current_photo) - width
		end
		if y_print + height > Screen.getImageHeight(current_photo) then
			y_print = Screen.getImageHeight(current_photo) - height
		end
	else
		Screen.drawImage(0,0,curent_photo,TOP_SCREEN)
	end
			
	-- Showing files list
	base_y = 0
	for l, file in pairs(my_photos) do
		if (base_y > 226) then
			break
		end
		if (l >= master_index_p) then
			if (l==p_p) then
				base_y2 = base_y
				if (base_y) == 0 then
					base_y = 2
				end
				Screen.fillRect(0,319,base_y-2,base_y2+12,selected_item,BOTTOM_SCREEN)
				color = selected
				if (base_y) == 2 then
					base_y = 0
				end
			else
				color = white
			end
			CropPrint(0,base_y,file[2],color,BOTTOM_SCREEN)
			base_y = base_y + 15
		end
	end
	
	-- Sets controls triggering
	if Controls.check(pad,KEY_B) or Controls.check(pad,KEY_START) then
		Screen.freeImage(current_photo)
		CallMainMenu()
	elseif (Controls.check(pad,KEY_DUP)) and not (Controls.check(oldpad,KEY_DUP)) and not_started then
		p_p = p_p - 1
		if (p_p >= 16) then
			master_index_p = p_p - 15
		end
		update_frame = true
	elseif (Controls.check(pad,KEY_DDOWN)) and not (Controls.check(oldpad,KEY_DDOWN)) and not_started then
		p_p = p_p + 1
		if (p_p >= 17) then
			master_index_p = p_p - 15
		end
		update_frame = true
	end
	if (p_p < 1) then
		p_p = #my_photos
		if (p_p >= 17) then
			master_index_p = p_p - 15
		end
	elseif (p_p > #my_photos) then
		master_index_p = 0
		p_p = 1
	end
end