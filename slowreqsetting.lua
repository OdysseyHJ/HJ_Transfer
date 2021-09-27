-- file: slowreqsetting.lua
-- author: hujunjun
-- date: 2021.9.9
-- function: ������Ĺ�������, ���������߼�

Setting = {}


-- ҵ����������
-- ֻ�����õ�ҵ��Ž���������ʶ��
local g_busi_type_table = {
    -- ֤ȯ�������ݣ�����ʵʱ���ݡ��̺����ݡ��ƾ����ݵ�
    [0x0009] = 1, 
    -- ��վ����
    [0x000f] = 1,
}


-- ��������ת����,ÿ��������Ӧһ����������,���������ȫ����������ʱ,����ת��
-- ���������ʽ��
-- [n] = {
--     ['market'] = 32,
--     ['datatime'] = 7178,
--     ['datatype'] = '199112', datatype����Ϊ�ַ���,����ĸ��Сд
-- }
local g_special_request_table = {
    [1] = {
        ['market'] = 32,
        ['datatype'] = '199112',
        ['datetime'] = 0,
    },

    [2] = {
        ['market'] = 32,
        ['datatype'] = 'new',
        ['datetime'] = 7184,
    }
}



-- ͨ�����ñ�,Ӱ����ϴ�,ֻҪһ���������㼴����ת��
local g_common_table = {
    -- ��Ҫת�����г�
    ["market"] = {
        -- [48] = 1,
        [168] = 1,
    },

    -- ��Ҫת��������
    ["datetime"] = {
        [12288] = 1,
    },

    -- ��Ҫת����������
    ["datatype"] = {
        ['3153'] = 1,
        ["very_complex"] = 1,
    },
}

--��ֵ������,������ֵ�ж�Ϊ������
local g_threshold_table = {
    ['period_threshold'] = 100,
}


-- ҵ�����ͼ��
function Setting.check_busi_type(busi_type)
    if g_busi_type_table[busi_type] == 1
    then
        return true
    end
    return false
end

-- ��������ת��
function Setting.check_special_request(tbl_check)
    for index, request in ipairs(g_special_request_table) do
        check_res = true
        for key,val in pairs(request) do
            -- print("now:", key,val)
            if tbl_check[key][val] == nil
            then
                -- print("skiped :", key, val)
                check_res = false
                break

            end
        end
        if check_res
        then 
            print("special request catched, index=", index)
            return true
        end
    end
    return false
end


-- common�������
function Setting.check_common_params(tbl_check)
    for param_type, params in pairs(tbl_check) do
        for param, val in pairs(params) do
            if g_common_table[param_type][param] ~= nil
            then
                print("param catched :", param_type, param)
                return true
            end
        end
    end
    return false
end

--��ֵ���
function Setting.check_threshold(tbl_check)
    for key, val in pairs(g_threshold_table) do
        if tbl_check[key] > val
        then
            print("threshold catched :", key, tbl_check[key])
            return true

        end
    end
    return false
end


return Setting