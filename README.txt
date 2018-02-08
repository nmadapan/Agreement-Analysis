'loa_data' --> 34 x 3 x 3 (No. of commands x [context, modifier, context+modifier] x [SOA, one-hot, SD])
    * Jaccard metric is used to compute this.

'full_loa_info' --> 34 x 5 (No. of commands x different modalities)
Modalities: [random, context, modifier, context+modifier, modifier-context]
Everything computed using Jaccard metric.
