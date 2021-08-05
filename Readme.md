**Configuration directory for all the projects**

## Include common.mk in project
```sh
# All the targets have been tested on ubuntu system
#-------------------------------------------------------------------------------------------
# ENV VARIABLES
#-------------------------------------------------------------------------------------------

export APP ?= <app name>

#-------------------------------------------------------------------------------------------
# APP VARIABLES 
#-------------------------------------------------------------------------------------------
.DEFAULT_GOAL = help
CONFIG_PATH ?= <path to bk-config>

#-------------------------------------------------------------------------------------------
# USE COMMON FILE TARGETS
#-------------------------------------------------------------------------------------------

ifneq (,$(wildcard $(CONFIG_PATH)/make/common.mk))
%: force
	@make -s -f $(CONFIG_PATH)/make/common.mk $@
force: ;
endif	
```