-- hmm

 select
  d.id as did,d.value as division,s.id as sid,s.value as subdivision,st.value as type
 from
  census_subdivision s
  left join census_subdivision_type st on st.id=s.sdtype_id
  left join census_div_sub ds on ds.subdivision_id=s.id
  left join census_division d on d.id=ds.division_id
 order by d.value, s.value, st.value
 ;


 select
  m.id, m.year, m.name
 from
  municipalities m
 order by m.name
 ;
 
