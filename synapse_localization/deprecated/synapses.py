from neuprint import Client
c = Client('neuprint.janelia.org', dataset='hemibrain:v1.2.1', token='eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6Im1oYWxwZXJAZ21haWwuY29tIiwibGV2ZWwiOiJub2F1dGgiLCJpbWFnZS11cmwiOiJodHRwczovL2xoMy5nb29nbGV1c2VyY29udGVudC5jb20vYS0vQU9oMTRHZ21mNzdBVklUZ25sM21uNlJWelUwNEsybVFkbVdBbE5RYzRtQUpwUT9zej01MD9zej01MCIsImV4cCI6MTgwNzQzNTUzMX0.SAw3l6BN1OGdJGwn6O9mCJnqm-UEYpr3gJEUUa0AmNg')
#npID = neuron_df['bodyId'][0]#get the first neuron in our list of "hits"

#NC = [882995659,914027038] #61933
#NC = [882995659] #61933
#572408934,789330613 adt4


from neuprint import NeuronCriteria as NC, SynapseCriteria as SC, fetch_synapses
#fetch_synapses(NC(bodyId=882995659),SC(rois=['AVLP(R)', 'PVLP(R)'], primary_only=True),client=c)
#h0 = fetch_synapses(NC(bodyId=882995659),SC(rois=['AVLP(R)', 'PVLP(R)'])) #restrict synapses to specific ROIs
#h0 = fetch_synapses(NC(bodyId=882995659),SC()) #unrestruc
h0 = fetch_synapses(NC(bodyId=572408934),SC(rois=['SMP(R)', 'SLP(R)']))


#from neuprint import NeuronCriteria as NC, SynapseCriteria as SC, fetch_synapse_connections
#h1 = fetch_synapse_connections(882995659, None, SC(rois=['AVLP(R)', 'PVLP(R)'], primary_only=True))



