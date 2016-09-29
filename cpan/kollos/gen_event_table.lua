    do
        local f = assert(io.open(event_file, "r"))
        local code_lines = {}
        local code_mnemonics = {}
        local max_code = 0
        while true do
            local line = f:read()
            if line == nil then break end
            local i,_ = string.find(line, "#")
            local stripped
            if (i == nil) then stripped = line
            else stripped = string.sub(line, 0, i-1)
            end
            if string.find(stripped, "%S") then
                local raw_code
                local raw_mnemonic
                local description
                _, _, raw_code, raw_mnemonic, description = string.find(stripped, "^(%d+)%sMARPA_EVENT_(%S+)%s(.*)$")
                local code = tonumber(raw_code)
                if description == nil then return nil, "Bad line in event code file ", line end
                if code > max_code then max_code = code end
                local mnemonic = 'LIBMARPA_EVENT_' .. raw_mnemonic
                code_mnemonics[code] = mnemonic
                code_lines[code] = string.format( '   { %d, %s, %s },',
                    code,
                    c_safe_string(mnemonic),
                    c_safe_string(description)
                    )
            end
        end

        io.write('#define LIBMARPA_MIN_EVENT_CODE 0\n')
        io.write('#define LIBMARPA_MAX_EVENT_CODE ' .. max_code .. '\n\n')

        for i = 0, max_code do
            local mnemonic = code_mnemonics[i]
            if mnemonic then
                io.write(
                       string.format('#define %s %d\n', mnemonic, i)
               )
           end
        end
        io.write('\n')
        io.write('struct s_libmarpa_event_code marpa_event_codes[LIBMARPA_MAX_EVENT_CODE-LIBMARPA_MIN_EVENT_CODE+1] = {\n')
        for i = 0, max_code do
            local code_line = code_lines[i]
            if code_line then
               io.write(code_line .. '\n')
            else
               io.write(
                   string.format(
                       '    { %d, "LUIF_EVENT_RESERVED", "Unknown Libmarpa event %d" },\n',
                       i, i
                   )
               )
            end
        end
        io.write('};\n\n');
        f:close()
    end
