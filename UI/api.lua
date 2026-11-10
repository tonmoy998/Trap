if UI_PATH == nil then
	UI_PATH = (...):match("(.-)[^%.]+$")
end

UI_FILE_PATH = debug.getinfo(1, "S").source:match("^@(.+)/")
UI_FILE_PATH = UI_FILE_PATH == nil and "" or UI_FILE_PATH

local UI = {}

-- Libraries
UI.Flux = require(UI_PATH .. ".libs.flux")
-- UI.Class = require(UI_PATH .. ".libs.class")

-- Global Options
UI.Options = require(UI_PATH .. ".options")

-- Components / Widgets
UI.Window = require(UI_PATH .. ".widgets.Window")
UI.Button = require(UI_PATH .. ".widgets.Button")
UI.Text = require(UI_PATH .. ".widgets.Text")
UI.Themes = require(UI_PATH .. ".themes.Themes")
UI.Img = require(UI_PATH .. ".widgets.Img")
UI.Slider = require(UI_PATH .. ".widgets.Slider")
UI.Toggle = require(UI_PATH .. ".widgets.Toggle")
UI.Rect = require(UI_PATH .. ".widgets.Rect")
UI.Tab = require(UI_PATH .. ".widgets.Tab")
-- UI.Button = require(UI_PATH .. ".widgets.Button")
--
-- Layouts
UI.Flex = require(UI_PATH .. ".layouts.Flex")

function UI.setDebug(debug)
	UI.Options.debug = not not debug
	if UI.Options.debug then
		print("[UI] Debug mode enabled")
	else
		print("[UI] Debug mode disabled")
	end
end

return UI
