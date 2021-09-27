-- file: slowreqcheck.lua
-- author: hujunjun
-- date: 2021.9.9
-- function: ???????,????lua?????????§¿???????????
package.path = package.path..';D:\\HJ_IN_Share\\hqserver0817\\10jqka\\cs\\lua\\?.lua'
package.path = package.path..';../lua/?.lua;/hxapp/hqserver-hjj/lua/?.lua;'
-- package.preload['./slowreqsetting']
-- print("hjjjjjjjjj----",package.path)

require ("bit")
require ("slowreqsetting")

-- ??szSeparator????????,????table
function Split(szFullString, szSeparator)
	local nFindStartIndex = 1
	local nSplitIndex = 1
    local nSplitArray = {}
    if szFullString ==nil or string.len(szFullString) == 0
    then
        -- ???????datatype?,????????
        return nSplitArray
    end
	while true do
		    local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)
		    if not nFindLastIndex then
				nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))
				break
            end
            sub_str = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)
            if string.len(sub_str) ~= 0 
            then
                nSplitArray[nSplitIndex] = sub_str
                nFindStartIndex = nFindLastIndex + string.len(szSeparator)
                nSplitIndex = nSplitIndex + 1
            end


	end
	return nSplitArray
end


-- ???str_start???????????str_end?????????,???????????????????
function get_sub_string(str_origin, str_start, str_end)

    local _, start_index = string.find(str_origin, str_start)
    -- print(start_index)
    if start_index == nil
    then
        return nil
    end
    local end_index = string.find(str_origin, str_end, start_index)
    -- print(start_index, end_index)

    -- ??¦Â¦Ä??????????????????
    if end_index == nil
    then
        end_index = string.len(str_origin)
    end
    local sub_string = string.sub(str_origin, start_index+1, end_index-1)
    -- print(sub_string)

    return sub_string
end

-- ????????,??str_split??????????,???????¦Ê?????,??????str_split
function string_split(str_origin, str_split)
    local start_index, end_index = string.find(str_origin, str_split)
    -- print(str_origin, start_index, end_index)
    str_first = string.sub(str_origin, 0, start_index-1)
    str_second = string.sub(str_origin, end_index+1)
    return str_first, str_second
end

-- ?§Ô????????????,????????
function codelist_parse(str_codelist)
    hash_market = {}
    if str_codelist == nil or string.len(str_codelist) == 0
    then
        -- ???????datatype?,????????
        return hash_market
    end

    temp_market = Split(str_codelist, ';')
    for i,sub_codelist in ipairs(temp_market) do
        if string.len(sub_codelist) ~= 0
        then
            sub_market, _ = string_split(sub_codelist, '%(')
            sub_market = tonumber(sub_market)
            -- print(sub_market)
            sub_market = bit.band(sub_market, 0xf8)
            hash_market[sub_market] = sub_market
        end
    end
    return hash_market
end

-- ???????,????(????,??????)
function datetime_parse(str_datetime)
    if str_datetime == nil 
    then 
        return 0, 0
    end

    period, rest_str = string_split(str_datetime, '%(')
    period_inteval,_ = string_split(rest_str, '%)')
    -- print(period_inteval)
    period_len = string.len(period_inteval)
    if period_len < 6
    then 
        -- ??datetime=0(-)??,???????????datetime?0(0-0),§³??????????,?????????0
        return tonumber(period), 0
    end

    period_split = 0
    for i = period_len, 1, -1 do
        if '-' == string.sub(period_inteval, i, i)
        then
            period_split = i
            break
        end
    end
    period_start = string.sub(period_inteval, 0, period_split-1)
    period_end = string.sub(period_inteval, period_split+1)
    -- print(period_start, period_end, period_end - period_start)
    return tonumber(period), period_end - period_start
end



-- ?????????,????????
function datatype_parse(str_datatype)
    hash_datatype = {}
    tbl_datatype = Split(str_datatype, ',')
    for _, datatype in ipairs(tbl_datatype) do
        hash_datatype[datatype] = datatype
    end
    return hash_datatype
end


-- ???????????
function slow_req_proc(sub_type, request_content)
    -- ????? start
    print(string.format("bussiness type: 0x%x", sub_type))
    if Setting.check_busi_type(sub_type) == false
    then
        print(string.format("0x%x is not slow bussiness type", sub_type))
        return false
    end

    -- ?????????? start
    -- ????????????§³§Õ,?????§³§Õ?§Ø?
    request_content = string.lower(request_content)
    print(request_content)
    str_codelist = get_sub_string(request_content, "codelist=", "&")
    str_datetime = get_sub_string(request_content, "datetime=", "&")
    str_datatype = get_sub_string(request_content, "datatype=", "&")
    print(str_codelist, str_datetime, str_datatype)

    -- ????§Ô???
    hash_market = codelist_parse(str_codelist)
    -- print(tbl_market[0])
    
    -- ??????????????
    period, period_count = datetime_parse(str_datetime)
    -- print(period, period_count)

    -- ???????datatype ??
    hash_datatype = datatype_parse(str_datatype)

    -- ????????????
    tbl_request = {
        ["market"] = hash_market,
        ["datetime"] = { [period] = 1},
        ["datatype"] = hash_datatype,
    }

    -- ??????????
    tbl_value = {
        ['period_threshold'] = period_count,
    }

    -- ?????????????????
    special_request_check_res = Setting.check_special_request(tbl_request)
    if special_request_check_res 
    then 
        print("Slow request!")
        return true
    end

    -- ????????????????????
    common_param_check_res = Setting.check_common_params(tbl_request)
    if common_param_check_res 
    then 
        print("Slow request!")
        return true
    end

    -- ??????
    threshold_check_res = Setting.check_threshold(tbl_value)
    if threshold_check_res
    then
        print("Slow request!")
        return true
    end


    print("Not slow request!")
    return false
end





local test_subtype = 9
local test_request = "Method=quote&Codelist=88(300033,300034);17();18();185();200()&DateTime=16385(-200-0)&DataType=55,10,199113,VERsY_COMPLEX&"
local test2 = "codelist=33(300033,300034);&datetime=0(0-0)&datatype=55,10&method=quote&"
local test3 = "codelist=33(300033,300034);&datetime=0(-)&datatype=55,10&method=quote&"
local test4 = "codelist=33(300033,300034);&datatype=55,10&method=quote&"
local test5 = "codelist=33(300033,300034);&datetime=0(-)&method=quote&"

slow_req_proc(test_subtype, test5)
