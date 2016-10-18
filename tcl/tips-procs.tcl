ad_library {

    API for the qss_TIPS api
    @creation-date 12 Oct 2016
    @cs-id $Id:
}

ad_proc -public qss_tips_table_id_of_label {
    table_label
} { 
    Returns table_id of table_name, or empty string if not found.
} {
    upvar 1 instance_id instance_id
    upvar 1 $name_array n_arr
    set table_id ""
    db_0or1_row qss_tips_table_defs_r_name {select id as table_id from qss_tips_table_defs
        where label=:table_name
        and instance_id=:instance_id}
    return $table_id
}


ad_proc -public qss_tips_table_def {
    table_label
} { 
    Returns list of table_id, label, name, flags, trashed_p or empty list if not found.
} {
    upvar 1 instance_id instance_id
    upvar 1 $name_array n_arr
    set table_list [list ]
    set exists_p [db_0or1_row qss_tips_table_defs_r1 {select id,label,name,flags,trashed_p from qss_tips_table_defs
        where label=:table_label
        and instance_id=:instance_id}]
    if { $exists_p } {
        set table_list [list $id $label $name $flags $trashed_p]
    }
    return $table_list
}


ad_proc -public qss_tips_table_create {
    label
    name
} {
    Defines a tips table. Label is a short reference with no spaces.
    Name is usually a title for display and has spaces.
    @return 1 if successful, otherwise 0
} {
    upvar 1 instance_id instance_id
    
    # fields need to be defined at the same time the table is, otherwise
    # if records exist, they will be missing fields..
    # which will lead to unexpected behavior unless a transition technqiue is defined.
    # How to handle. Treat like spreadsheets, when a column is added..
    # New columns start with empty values.
    # This should also help when importing data. A new column could be temporarily added,
    # then removed after data has been integrated into other columns for example.
    # 
    # sql doesn't have to create an empty data.
    # When reading, assume column is empty, unless data exists -- consistent with simple_tables
    set success_p 0
    if { [hf_are_printable_characters_q $label] && [hf_are_visible_characters_q $title] } {
        set existing_id [qss_tips_table_id_of_label $label]
        if { $existing_id eq "" } {
            set id [db_nextval qss_tips_id_seq]
            set flags ""
            set trashed_p "0"
            db_dml qss_tips_table_cre {
                insert into qss_tips_table_defs 
                (instance_id,id,label,name,flags,trashed_p)
                values (:instance_id,:id,:label,:name,:flags,:trashed_p)                   
            }
            set success_p 1
        }
    }
    return $success_p
}

ad_proc -public qss_tips_table_update {
    label
    name
    {id ""}
} {
    Given id, updates label and name (if not empty string). Given label, updates name.
    @return 1 if successful, otherwise return 0.
} {


}

ad_proc -public qss_tips_table_trash {

} {
    Trashes a tips table
} {

}

ad_proc -public qss_tips_field_add {

} {
    Adds one or more fields
} {

}

ad_proc -public qss_tips_field_trash {

} {
    Trashes one or more fields
} {

}


ad_proc -private qss_tips_field_defs {
    table_label
    {table_id ""}
} { 
    Returns list of lists of table_label, where colums are field_id,label,name,default_val,tdt_data_type,field_type or empty list if not found.
} {
    upvar 1 instance_id instance_id
    upvar 1 $name_array n_arr
    if { $table_id eq "" } {
        set table_id [qss_tips_table_id_of_label $table_label]
    }
    set fields_lists [db_list_of_lists qss_tips_field_defs_r {select id as field_id,label,name,default_val,tdt_data_type,field_type from qss_tips_field_defs
        where instance_id=:instance_id
        and table_id=:table_id}]
    return $fields_lists
}



ad_proc -public qss_tips_write {
    name_array
    table_label
} {
    Writes a record into table_label. Returns row_id if successful, otherwise empty string.
} {
    upvar 1 instance_id instance_id
    upvar 1 $name_array n_arr
    set row_id ""
    if { [nsconn isconnected] } {
        set user_id [ad_conn user_id]
    } else {
        set user_id 0
    }


    return $row_id
}

ad_proc -public qss_tips_table_write {
    name_array
    table_label
} {
    Creates or writes a record into table_label. Returns row_id if successful, otherwise empty string.
} {
    upvar 1 instance_id instance_id
    upvar 1 $name_array n_arr
    set row_id ""
    if { [nsconn isconnected] } {
        set user_id [ad_conn user_id]
    } else {
        set user_id 0
    }

    return $row_id
}

ad_proc -public qss_tips_val {
    table_label
    search_label
    search_value
    return_val_label_list
    {version "latest"}
} {
    Returns the values of the field labels in return_val_label_list in order in list.
    If only one label is supplied for return_val_label_list, a scalar value is returned instead of list.
    If more than one record matches search_value for search_label, the version
    determines which version is chosen. Cases are "earliest" or "latest"
} {



    return $return_val
}

ad_proc -public qss_tips_table_read {
    name_array
    table_label
    {vc1k_search_label_val_list ""}
    {trashed_p "0"}
    {row_id_list ""}
} {
    Returns one or more records of table_label as an array
    where field value pairs in vc1k_search_label_val_list match query.
    array indexes are name_array(row_id,field_label)
    where row_id are in a list in name_array(row_ids)
    Defaults to return all untrashed rows of table.
    If trashed_p is 0, returns only records that are untrashed.
    If row_id_list contains row_ids, only returns ids that are in this set.
} {
    upvar 1 instance_id instance_id
    upvar 1 $name_array n_arr
    set table_id [qss_tips_table_id_of_name $table_label]
    set success_p 0

    if { $table_id ne "" } {
        set fields_lists [qss_tips_field_defs $tabel_label $table_id]
        if { [llength $fields_lists ] > 0 } {
            foreach field_list $field_lists {
                foreach {field_id label name def_val tdt_type field_type} $fields_list {
                    set type_arr(${field_id}) $field_type
                    set label_arr(${field_id}) $label
                    set field_id_arr(${label}) $field_id
                }
            }
            if { [qf_is_true $trashed_p] } {
                set trashed_sql ""
            } else {
                set trashed_sql "and trashed_p!='1'"
            }

            set row_ids_sql ""
            if { $row_id_list ne "" } {
                # filter to row_id_list
                if { [hf_natural_number_list_validate $row_id_list] } {
                    set row_ids_sql "and row_id in ([template::util::tcl_to_sql_list $row_id_list])"
                } else {
                    ns_log Warning "qss_tips_read.31: One or more row_id are not a natural number '${row_id_list}'"
                    set row_ids_sql "na"
                }
            }
            set vc1k_search_sql ""
            if { $vc1k_search_label_val ne "" } {
                # search scope
                foreach {label vc1k_search_val} $vc1k_search_label_val_list {
                    if { [info exists field_id_arr(${label}) ] && $vc1k_search_sql ne "na" } {
                        set field_id $field_id_arr(${label})
                        append vk1k_search_sql " and (field_id='${field_id}' and f_vc1k='${vc1k_search_val}')"
                    } else {
                        ns_log Warning "qss_tips_read.37: no field_id for search label '${label}' table_label '${table_label}' "
                        set vc1k_search_sql "na"
                    }
                }
            }

            if { $row_ids_sql eq "na" || $vc1k_search_sql eq "na" } {
                set n_arr(row_ids) [list ]
            } else {
                set values_lists [db_list_of_lists qss_tips_field_values_r "select field_id, f_vc1k, f_nbr, f_txt, row_id from qss_tips_field_values 
        where table_id=:table_id
        and instance_id=:instance_id ${trashed_sql} ${vc1k_search_sql} ${row_ids_sql}"]
                
                # val_i = values initial
                set row_ids_list [list ]
                foreach {field_id f_vc1k f_nbr f_txt row_id} $values_lists {
                    lappend row_ids_list $row_id
                    # since only one case of field value should be nonempty,
                    # following logic could be sped up using qal_first_nonempty_in_list
                    if { [info exists type_arr(${field_id}) ] } {
                        switch -exact -- $type_arr(${field_id}) {
                            vc1k { set v $f_vc1k }
                            nbr  { set v $f_nbr }
                            txt  { set v $f_txt }
                            default {
                                ns_log Warning "qss_tips_read.47: unknown type for table_label '${table_label}' field_id '${field_id}' row_id '${row_id}'"
                                set v [qal_first_nonempty_in_list [list $f_nbr $f_vc1k $f_txt]]
                            }
                        }
                    } else {
                        ns_log Warning "qss_tips_read.54: field_id does not have a field_type. table_label '${table_label}' field_id '${field_id}' row_id '${row_id}'"
                    }
                    set label $label_arr(${field_id})
                    set n_arr(${label},${row_id}) $v
                }
                set n_arr(row_ids) [lsort -unqiue -integer $row_ids_list]
                if { [llength $values_lists] > 0 } {
                    set success_p 1
                }
            }
        }
    }
    return $success_p
}

