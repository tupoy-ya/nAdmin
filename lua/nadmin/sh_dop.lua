local string = string
string.oldupper = string.oldupper or string.upper
string.oldlower = string.oldlower or string.lower
local _gmatch = string.gmatch

local lowers = {['А']='а',['Б']='б',['В']='в',['Г']='г',['Д']='д',['Е']='е',['Ё']='ё',['Ж']='ж',['З']='з',['И']='и',['Й']='й',['К']='к',['Л']='л',['М']='м',['Н']='н',['О']='о',['П']='п',['Р']='р',['С']='с',['Т']='т',['У']='у',['Ф']='ф',['Х']='х',['Ц']='ц',['Ч']='ч',['Ш']='ш',['Щ']='щ',['Ъ']='ъ',['Ы']='ы',['Ь']='ь',['Э']='э',['Ю']='ю',['Я']='я'}
local uppers = {['а']='А',['б']='Б',['в']='В',['г']='Г',['д']='Д',['е']='Е',['ё']='Ё',['ж']='Ж',['з']='З',['и']='И',['й']='Й',['к']='К',['л']='Л',['м']='М',['н']='Н',['о']='О',['п']='П',['р']='Р',['с']='С',['т']='Т',['у']='У',['ф']='Ф',['х']='Х',['ц']='Ц',['ч']='Ч',['ш']='Ш',['щ']='Щ',['ъ']='Ъ',['ы']='Ы',['ь']='Ь',['э']='Э',['ю']='Ю',['я']='Я'}

function string.upperRus(str)
	local result = ''

	for char in _gmatch(str, '[%z\x01-\x7F\xC2-\xF4][\x80-\xBF]*') do
		result = result .. (uppers[char] or string.oldupper(char))
	end

	return result
end

function string.lowerRus(str)
	local result = ''

	for char in _gmatch(str, '[%z\x01-\x7F\xC2-\xF4][\x80-\xBF]*') do
		result = result .. (lowers[char] or string.oldlower(char))
	end

	return result
end

function meta:NameWithoutTags()
	local arg1 = self:Name():gsub("<([/%a]*)=?([^>]*)>", "")
	return arg1
end

function StringWithoutTags(txt)
	local arg1 = txt:gsub("<([/%a]*)=?([^>]*)>", "")
	return arg1
end
