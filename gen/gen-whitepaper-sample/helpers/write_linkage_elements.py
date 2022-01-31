# Copyright © 2021 Broadcom

# print Members for Pstep/Screen
def write_linkage_elements(directive_dict, dependency_map, type_of_directive, template_dir, elem_tracker, context):
    for name, pstep_item in directive_dict.items():
        if pstep_item['link'] == 'DYNAMIC':
            is_dynamic = True
            write_lnk(pstep_item['member'], template_dir, elem_tracker, context)
            write_lnkinc_dynamic(
                pstep_item['member'],
                pstep_item['include'],
                dependency_map,
                template_dir,
                type_of_directive,
                elem_tracker,
                context)


# process LNKINC for dynamic elem
def write_lnkinc_dynamic(filename, incs, dependency_map, template_dir, type_of_directive, elem_tracker, context):
    with open(template_dir / 'LNKINC' / filename, 'w') as lnkinc_file:
        lnkinc_file.write(context.vals['linkedit']['INC_CEHBSIDE'].format(filename=filename) + '\n')
        lnkinc_file.write(context.vals['linkedit']['INC_AEHBMOD0'].format(filename=filename) + '\n')

        if len(incs) >= 0:
            if type_of_directive == "acblk" and filename in dependency_map:
                for val in dependency_map[filename]:
                    lnkinc_file.write(context.vals['linkedit']['INC_AEHBMOD0'].format(filename=val) + '\n')
            else:
                for inc in incs:
                    lnkinc_file.write(context.vals['linkedit']['INC_AEHBMOD0'].format(filename=inc) + '\n')
                    elem_tracker['dyn_ri_modules'].add(inc)
                    if inc in dependency_map:
                        for val in dependency_map[inc]:
                            lnkinc_file.write(context.vals['linkedit']['INC_AEHBMOD0'].format(filename=val) + '\n')
                            elem_tracker['dyn_ri_modules'].add(val)

        lnkinc_file.write(context.vals['linkedit']['MODE_STR'] + '\n')
        lnkinc_file.write(context.vals['linkedit']['SETOPT_CALL'] + '\n')
        lnkinc_file.write(context.vals['linkedit']['ENTRY'].format(filename=filename) + '\n')


# Write all LNK Members
def write_lnk(filename, template_dir, elem_tracker, context):
    with open(template_dir / 'LNK' / filename, 'w') as lnkfile:
        lnkfile.write(context.vals['linkedit']['INC_INCLIB'].format(filename=filename) + '\n')
        lnkfile.write(context.vals['linkedit']['NAME'].format(filename=filename) + '\n')


# Write The dialog Module
def write_dialog_module(filename, template_dir, icm_static_dict, icm_module_dict, elem_tracker, context):
    with open(template_dir / 'LNKINC' / filename, 'a') as dialogfile:
        dialogfile.write(context.vals['linkedit']['INC_CEHBSIDE'].format(filename=filename) + '\n')
        for sm in sorted(icm_static_dict.keys()):
            if sm not in elem_tracker['dyn_ri_modules']:
                dialogfile.write(context.vals['linkedit']['INC_AEHBMOD0'].format(filename=sm) + '\n')
        for mem in icm_module_dict.keys():
            dialogfile.write(context.vals['linkedit']['IMPORT_CODE'].format(member=mem) + '\n')
        dialogfile.write(context.vals['linkedit']['INC_AEHBMOD0'].format(filename=filename) + '\n')
        dialogfile.write(context.vals['linkedit']['MODE_STR'] + '\n')
        dialogfile.write(context.vals['linkedit']['SETOPT_CALL'] + '\n')
        write_lnk(filename, template_dir, elem_tracker, context)
