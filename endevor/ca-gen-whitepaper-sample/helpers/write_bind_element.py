# Copyright © 2021 Broadcom
from pathlib import Path


def write_bind_element(icm_dict, exec_unit, depenency_map, template_dir, context):
    procconfig = context.vals['processing']['db2_bind']
    tmplconfig = context.vals['templates']['db2_bind']

    stages = procconfig['stages']
    template_vars = tmplconfig['vars']
    dsn_template = tmplconfig['content']['dsn']
    member_template = tmplconfig['content']['bind_member']
    plan_template = tmplconfig['content']['bind_plan']
    mbrcoll = exec_unit['mbrcoll'].rstrip('.')
    if 'gen_runtime_collection_id' in template_vars and template_vars['gen_runtime_collection_id']:
        gen_runtime_collection_id = ', ' + template_vars['gen_runtime_collection_id']
    else:
        gen_runtime_collection_id = ""

    parms_dir = template_dir / Path("PARMS")

    db2sys = template_vars['db2_sys_name']
    for module_name, includes in depenency_map.items():
        bind_card_items = set()
        if icm_dict[module_name]['sql']:
            bind_card_items.add(module_name)
        bind_card_items.update(includes)

        for stage in stages:
            with open(parms_dir / (module_name + stage['elem_suffix']), "w") as dbrm_file:
                dbrm_file.write(dsn_template.format(db2_sys_name=db2sys))
                dbrm_file.write('\n\n')

                for incl_element_name in bind_card_items:
                    incl_element = icm_dict[incl_element_name]
                    collection = incl_element['collection'].rstrip('.')
                    user = template_vars['user'].upper()
                    qualifier = template_vars['qualifier'].upper()

                    dbrm_file.write(member_template.format(
                        dbrmlib=stage['dsn'],
                        dbrm_member_name=incl_element_name,
                        collection=collection,
                        user=user,
                        qualifier=qualifier))
                    dbrm_file.write('\n')
                # we only need to do this once for the entire application, so it's done in the dialog manager
                if module_name == exec_unit['member']:
                    dbrm_file.write(plan_template.format(
                        lnk_elem_name=module_name,
                        mbr_coll=mbrcoll,
                        gen_runtime_collection_id=gen_runtime_collection_id))
