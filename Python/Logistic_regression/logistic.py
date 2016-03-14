import pandas as pd
import scipy.stats as stats

#input data
input = '/Users/Jovial/Desktop/4201/datagradecleaned.csv'
input_data = pd.read_csv(input)
predictors = ['index','BORO','CUISINE.DESCRIPTION']
response = ['GRADE']
input_data = input_data[['index','BORO','CUISINE.DESCRIPTION','GRADE']]

#Filter sample data
input_n = len(input_data.index)
clean_data_0 = input_data[input_data['GRADE'].isin(['A','B','C'])]
clean_data_1 = clean_data_0[clean_data_0['BORO'] != 'Missing']
clean_data_2 = clean_data_1.groupby('CUISINE.DESCRIPTION').count()
clean_data_3 = clean_data_2[clean_data_2['index']>69978*0.02]
clean_data = clean_data_1[clean_data_1['CUISINE.DESCRIPTION'].isin(['American ','Caribbean',
'Chinese','Italian','Japanese','Latin (Cuban, Dominican, Puerto Rican, South & Central American)',
'Mexican'])]
clean_n_boro = len(clean_data_1.index)
clean_n_cuisine = len(clean_data.index)

#Summarize sample data by cuisine type
clean_data.groupby('GRADE').count()
clean_data.groupby('CUISINE.DESCRIPTION').count()

for i in ['American ','Caribbean','Chinese','Italian','Japanese','Latin (Cuban, Dominican, Puerto Rican, South & Central American)',
'Mexican']: 
        print clean_data[clean_data['CUISINE.DESCRIPTION'].isin([i])].groupby('GRADE').count()

#Summarize sample data by borough
clean_data_1.groupby('GRADE').count()
clean_data_1.groupby('BORO').count()

for j in ['BRONX','BROOKLYN','MANHATTAN','QUEENS','STATEN ISLAND']: 
        print clean_data_1[clean_data_1['BORO'].isin([j])].groupby('GRADE').count()

#Calculate odds ratio under cuisine type
oddsratio, pvalue = stats.fisher_exact([[10246,17792-10246], [19059-10246,36455-19059-5386-2160]]) #American
oddsratio, pvalue = stats.fisher_exact([[918,1836-918], [19059-918,36455-19059-615-303]]) #Caribbean
oddsratio, pvalue = stats.fisher_exact([[3042,6581-3042], [19059-3042,36455-19059-2363-1176]]) #Chinese
oddsratio, pvalue = stats.fisher_exact([[1676,3230-1676], [19059-1676,36455-19059-1108-446]]) #Italian
oddsratio, pvalue = stats.fisher_exact([[943,2153-943], [19059-943,36455-19059-840-370]]) #Japanese
oddsratio, pvalue = stats.fisher_exact([[1173,2633-1173], [19059-1173,36455-19059-1001-459]]) #Latin
oddsratio, pvalue = stats.fisher_exact([[1061,2230-1061], [19059-1061,36455-19059-810-359]]) #Mexican
oddsratio
pvalue

#Calculate odds ratio under borough
oddsratio, pvalue = stats.fisher_exact([[3835,6150-3835], [38252-3835,69978-38252-1877-798]]) #Bronx
oddsratio, pvalue = stats.fisher_exact([[9125,16597-9125], [38252-9125,69978-38252-5247-2225]]) #Brooklyn
oddsratio, pvalue = stats.fisher_exact([[15620,28688-15620], [38252-15620,69978-38252-9092-3976]]) #Manhattan
oddsratio, pvalue = stats.fisher_exact([[8223,15580-8223], [38252-8223,69978-38252-5169-2188]]) #Queens
oddsratio, pvalue = stats.fisher_exact([[1449,2603-1449], [38252-1449,69978-38252-809-345]]) #Staten Island
oddsratio
pvalue

#Calculate odds ratio under American restaurant
clean_data_american = clean_data[clean_data['CUISINE.DESCRIPTION'].isin(['American '])]
clean_data_american.groupby('BORO').count()
clean_data_american.groupby('GRADE').count()

for n in ['BRONX','BROOKLYN','MANHATTAN','QUEENS','STATEN ISLAND']: 
        print clean_data_american[clean_data_american['BORO'].isin([n])].groupby('GRADE').count()

oddsratio, pvalue = stats.fisher_exact([[729,1171-729], [10246-729,17792-10246-317-125]]) #Bronx
oddsratio, pvalue = stats.fisher_exact([[2136,3661-2136], [10246-2136,17792-10246-1109-416]]) #Brooklyn
oddsratio, pvalue = stats.fisher_exact([[5226,9263-5226], [10246-5226,17792-10246-2846-1191]]) #Manhattan
oddsratio, pvalue = stats.fisher_exact([[1760,3010-1760], [10246-1760,17792-10246-902-348]]) #Queens
oddsratio, pvalue = stats.fisher_exact([[395,687-395], [10246-395,17792-10246-212-80]]) #Staten Island
oddsratio
pvalue

#Logistic regression
clean_data_other = clean_data_1[~clean_data_1['CUISINE.DESCRIPTION'].isin(['American ','Caribbean',
'Chinese','Italian','Japanese','Latin (Cuban, Dominican, Puerto Rican, South & Central American)',
'Mexican'])]
clean_data_other.groupby('GRADE').count()
oddsratio, pvalue = stats.fisher_exact([[19193,10071+4259], [19059,69978-19059-19193-10071-4259]])
