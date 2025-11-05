-- UCRM v1 — STARTER VALUE SETS (examples; extend per your mappings)

-- CathPCI primary indication (example codes)
insert into map_value_sets (value_set_name, registry_code, normalized_code, normalized_label) values
('CATHPCI_INDICATION','1','STEMI','ST-Elevation MI')
on conflict do nothing;

insert into map_value_sets (value_set_name, registry_code, normalized_code, normalized_label) values
('CATHPCI_INDICATION','2','NSTEMI','Non-ST-Elevation MI')
on conflict do nothing;

insert into map_value_sets (value_set_name, registry_code, normalized_code, normalized_label) values
('CATHPCI_INDICATION','3','UA','Unstable Angina')
on conflict do nothing;

-- Access site
insert into map_value_sets (value_set_name, registry_code, normalized_code, normalized_label) values
('ACCESS_SITE','1','RADIAL','Radial')
on conflict do nothing;

insert into map_value_sets (value_set_name, registry_code, normalized_code, normalized_label) values
('ACCESS_SITE','2','FEMORAL','Femoral')
on conflict do nothing;

