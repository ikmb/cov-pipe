process PANGOLIN_LOOKUP {

        executor 'local'

        output:
        path("alias_key.json"), emit: json

        script:

        """
                wget https://raw.githubusercontent.com/cov-lineages/pango-designation/master/pango_designation/alias_key.json
        """
}


