package terraform.policies.public_ingress

test_deny_public_ingress if {
  tfplan_input := {
    "plan": {
      "resource_changes": [
        {
          "address": "aws_security_group.ecs_security_group",
          "type": "aws_security_group",
          "change": {
            "after": {
              "ingress": [
                {"cidr_blocks": ["0.0.0.0/0"]}
              ]
            }
          }
        }
      ]
    }
  }

  results := deny with input as tfplan_input
  results[_] == "aws_security_group.ecs_security_group has 0.0.0.0/0 as allowed ingress"
}

test_allow_specific_cidr if {
  tfplan_input := {
    "plan": {
      "resource_changes": [
        {
          "address": "aws_security_group.ecs_security_group",
          "type": "aws_security_group",
          "change": {
            "after": {
              "ingress": [
                {"cidr_blocks": ["192.168.1.0/24"]}  # Specific allowed CIDR
              ]
            }
          }
        }
      ]
    }
  }

  results := deny with input as tfplan_input
  count(results) == 0  # Should not deny specific CIDR
}

# Additional test for a different specific CIDR
test_allow_another_specific_cidr if {
  tfplan_input := {
    "plan": {
      "resource_changes": [
        {
          "address": "aws_security_group.ecs_security_group",
          "type": "aws_security_group",
          "change": {
            "after": {
              "ingress": [
                {"cidr_blocks": ["10.0.1.0/24"]}  # Another specific allowed CIDR
              ]
            }
          }
        }
      ]
    }
  }

  results := deny with input as tfplan_input
  count(results) == 0  # Should not deny this specific CIDR either
}
