# Copyright © 2021 Broadcom

def parse_section_data(data_lines, section_list=('execunit', 'pstep', 'screen', 'acblk')):
    """
    Parses an ICM and turns the different "sections" of the ICM into a dict of dicts. The key is the member name
    of the item in the ICM and the value is a dict of all the properties. Repeated properties (ex: include) are
    turned into sets. YES/NO values are Python True/False and everything else is treated as a string.

    :param data_lines: The ICM text content
    :param section_list: The list of sections types to parse, default value is probably what you want.
    :return: A dict of dicts, where the key is the member name of the item and the value is a dict of properties
    """
    metadata_dict = {}
    section_headers = set()
    for section in section_list:
        section_headers.add(':' + section)

    # this is not the most optimal way to process the data (there is a fair amount of rescanning of
    # data we have already processed, but apart from the performance loss, there is no
    # functional problem with the code or parsing
    for line_idx, data_line in enumerate(data_lines):
        data_line = data_line.strip()
        if data_line in section_headers:
            section_key = data_line[1:]
            current_line_idx = line_idx
            current_line = data_lines[current_line_idx]
            # set up object with default values for things that may be missing
            # they will be added-to/overwritten below, if encountered
            section_object = {'include': set(), 'link': 'STATIC', 'sql': False, 'section': section_key}

            while not current_line.endswith('.'):
                current_line_idx = current_line_idx + 1
                current_line = data_lines[current_line_idx]
                key, val = current_line.split('=')
                # convert YES/NO to True/False
                if val == 'NO':
                    val = False
                elif val == 'YES':
                    val = True
                if key in section_object.keys():
                    if isinstance(section_object[key], set):
                        section_object[key].add(val)
                    else:
                        section_object[key] = val
                else:
                    section_object[key] = val

            # Append all the dictionaries to a list
            if 'member' in section_object:
                item_name = section_object['member']
            else:
                raise Exception("no identifying key in ICM")

            if item_name in metadata_dict.keys():
                raise Exception("Unable to handle duplicate name in ICM")
            else:
                metadata_dict[item_name] = section_object
    return metadata_dict


def build_bind_card_dict(metadata_dict):
    """ Builds a dict of load modules and the static objects that belong to them. The twist is that each static
    object can only belong to one load module so there are no duplicates. So this is not an accurate reflection
    of the required linkage of the load modules, it is useful for building the DB2 bind cards.

    :param metadata_dict: the dict from a call to parse_section_data
    :return A dict of string keys (one per load module) mapped to a set of static objects
    """
    dep_map = {}
    all_static_objects_processed = set()
    exec_unit_id = None
    for name, item in metadata_dict.items():
        item_static_objects_found = set()
        if item['section'] == 'execunit':
            exec_unit_id = name
            dep_map[name] = item_static_objects_found
        elif item['link'] == 'DYNAMIC':
            dep_map[name] = item_static_objects_found
            if len(item['include']) > 0:
                recurse_includes(item,
                                 metadata_dict,
                                 item_static_objects_found,
                                 lambda include_item_id: metadata_dict[include_item_id]['sql'])
                dep_map[name] = item_static_objects_found
                all_static_objects_processed.update(item_static_objects_found)

    dep_map[exec_unit_id] = set()
    # now that we're done processing the includes, attach all other statically linked objects to the dialog manager
    for name, item in metadata_dict.items():
        if name != exec_unit_id \
                and name not in all_static_objects_processed \
                and metadata_dict[name]['link'] == 'STATIC'\
                and metadata_dict[name]['sql']:
            dep_map[exec_unit_id].add(name)

    return dict(filter(lambda kv_tuple: len(kv_tuple[1]) > 0 or metadata_dict[kv_tuple[0]]['sql'], dep_map.items()))


def recurse_includes(item, metadata_dict, accumulator, filter_func):
    for include_item_id in item['include']:
        include_item = metadata_dict[include_item_id]
        if include_item_id not in accumulator and filter_func(include_item_id):
            accumulator.add(include_item_id)
            recurse_includes(include_item, metadata_dict, accumulator, filter_func)


# Get all the Linked members for the Actionblock type Standard
# Input is the Actionblock list of dictionaries
def get_linked_members_for_standard(icm_acblk_dict):
    dependency_map = {}
    for name, actionblock_item in icm_acblk_dict.items():
        if actionblock_item['abtype'] == 'STANDARD':
            # For the actionblock type standard process it if it has include members
            if len(actionblock_item['include']) != 0:
                # for each of the include of the Action blocks capture its RI's links
                for lnk in actionblock_item['include']:
                    search_links(lnk, actionblock_item['member'], dependency_map, icm_acblk_dict, [], [])
    return dependency_map


# Calculate the difference of lists i.e to get the
# RI's Remaining members of the list so that it can fetch for all
def diff(list1, list2):
    c = set(list1).union(set(list2))  # or c = set(list1) | set(list2)
    d = set(list1).intersection(set(list2))  # or d = set(list1) & set(list2)
    return list(c - d)


# This function is called recursively to get all the Ri's involved for
# each of the Action block Standard Include member
def search_links(lnk, member, dependency_map, icm_acblk_dict, lnkset, lnklist):
    # add the include member to the List
    lnklist.append(lnk)
    if lnk not in lnkset:
        lnkset.append(lnk)
    for name, acblk_info in icm_acblk_dict.items():
        if acblk_info['member'] == lnk:
            if len(acblk_info['include']) != 0:
                for k in acblk_info['include']:
                    if k not in lnklist:
                        lnklist.append(k)

        lnk_diffs = diff(lnklist, lnkset)
        if len(lnk_diffs) != 0:
            lnk = lnk_diffs[0]
            # print("new lnk:"+lnk)
            search_links(lnk, member, dependency_map, icm_acblk_dict, lnkset, lnklist)
    # Remove the duplicates by converting to a set and put it in the Dictionary
    dependency_map[member] = set(lnklist)
