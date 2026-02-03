package terraform.analysis

import input as tfplan



#no securiyt group ports should be left wide open
deny_open_security_group_ports[resource] {
    resource := tfplan.resource_changes[resource_id]
    resource.type == "aws_security_group_rule"
    resource.change.after.cidr_blocks[_] == "0.0.0.0/0"
    message := sprintf("Security group rule %v allows open access from anywhere (0.0.0.0/0)", resource.change.after.security_group_id)
    resource := {
        "id": resource_id,
        "message": message


}   

