//
// This file holds several functions specific to the workflow/esga.nf in the nf-core/esga pipeline
//

class WorkflowPipeline {

    //
    // Check and validate parameters
    //
    public static void initialise(params, log) {


        if (!params.run_name) {
		log.info  "Must provide a run_name (--run_name)"
	        System.exit(1)
        }
	if (!params.run_date) {
		log.info "Must provide a run date (--run_date) as YYYY-MM-DD"
		System.exit(1)
	}
	if (params.folder && params.samples) {
		log.info "Can only provide one type of input!"
		System.exit(1)
	}
	if (!params.folder && !params.samples) {
		log.info "Most provide some kind of input!"
		System.exit(1)
	}    

    }

}
