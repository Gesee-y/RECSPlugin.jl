#######################################################################################################################
###################################################### RECS PLUGIN ####################################################
#######################################################################################################################

module RECSPlugin

export RECSPLUGIN

using Reexport
using Cruise
@reexport using ReactiveECS

struct RECSException <: Exception
	msg::String
end

const RECSPLUGIN = CRPlugin()
const WORLD = ECSManager()
PHASE = :postupdate

const ID = add_system!(RECSPLUGIN, WORLD)

ReactiveECS.connect(ON_ERROR) do msg,err
	node = RECSPLUGIN.idtonode[ID]
	setstatus(node, PLUGIN_ERR)
	setlasterr(node, RECSException(msg*err))
end

################################################# PLUGIN LIFECYCLE ####################################################

function Cruise.awake!(n::CRPluginNode{ECSManager})
	setstatus(n, PLUGIN_OK)
end

function Cruise.update!(n::CRPluginNode{ECSManager})
	dispatch_data(WORLD)
	blocker(WORLD)
end

function Cruise.shutdown!(n::CRPluginNode{ECSManager})
	setstatus(n, PLUGIN_OFF)
end

################################################## OTHER FUNCTIONS #####################################################

