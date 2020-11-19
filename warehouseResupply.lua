-- Name: Warehouse Resupply
-- Author: Wildcat (Chandawg)
-- Date Created: 28 Apr 2020
-- Trying to integrate the Alpha warehouse system from moose into RSR. Initially this will replace base units
-- Ultimately I couldn't integrate this into RSR-Caucuses because of the capture mechanism, but with the new Syria map we revamped the capture mechanism and went with Moose Zone Capture, so now exploring using these with RSR-Syria


local warehouse={}
----function to check if a save warehouse file exist, stole it from pikey's SGS
function file_exists(name) --check if the file already exists for writing
    if lfs.attributes(name) then
    return true
    else
    return false end 
end

----warehouseBatumi=WAREHOUSE:New(STATIC:FindByName("Warehouse Batumi"), "My optional Warehouse Alias")
----Defines the warehouses
--the string is the name in the mission editor
warehouse.AbualDuhur=WAREHOUSE:New(STATIC:FindByName("Abu al-Duhur Warehouse"))
warehouse.AdanaSakirpasa=WAREHOUSE:New(STATIC:FindByName("Adana Sakirpasa Warehouse"))
warehouse.AlDumayr=WAREHOUSE:New(STATIC:FindByName("Al-Dumayr Warehouse"))
warehouse.Aleppo=WAREHOUSE:New(STATIC:FindByName("Aleppo Warehouse"))
warehouse.AlQusayr=WAREHOUSE:New(STATIC:FindByName("Al Qusayr Warehouse"))
warehouse.AnNasiriyah=WAREHOUSE:New(STATIC:FindByName("An Nasiriyah Warehouse"))
warehouse.BasselAlAssad=WAREHOUSE:New(STATIC:FindByName("Bassel Al-Assad Warehouse"))
warehouse.BeirutRaficHariri=WAREHOUSE:New(STATIC:FindByName("Beirut-Rafic Hariri Warehouse"))
warehouse.Damascus=WAREHOUSE:New(STATIC:FindByName("Damascus Warehouse"))
warehouse.EynShemer=WAREHOUSE:New(STATIC:FindByName("Eyn Shemer Warehouse"))
warehouse.Haifa=WAREHOUSE:New(STATIC:FindByName("Haifa Warehouse"))
warehouse.Hama=WAREHOUSE:New(STATIC:FindByName("Hama Warehouse"))
warehouse.Hatay=WAREHOUSE:New(STATIC:FindByName("Hatay Warehouse"))
warehouse.Incirlik=WAREHOUSE:New(STATIC:FindByName("Incirlik Warehouse"))
warehouse.Jirah=WAREHOUSE:New(STATIC:FindByName("Jirah Warehouse"))
warehouse.Khalkhalah=WAREHOUSE:New(STATIC:FindByName("Khalkhalah Warehouse"))
warehouse.KingHusseinAirCollege=WAREHOUSE:New(STATIC:FindByName("King Hussein Air College Warehouse"))
warehouse.KiryatShmona=WAREHOUSE:New(STATIC:FindByName("Kiryat Shmona Warehouse"))
warehouse.Kuweires=WAREHOUSE:New(STATIC:FindByName("Kuweires Warehouse"))
warehouse.MarjasSultanNorth=WAREHOUSE:New(STATIC:FindByName("Marj as Sultan North Warehouse"))
warehouse.MarjasSultanSouth=WAREHOUSE:New(STATIC:FindByName("Marj as Sultan South Warehouse"))
warehouse.MarjRuhayyil=WAREHOUSE:New(STATIC:FindByName("Marj Ruhayyil Warehouse"))
warehouse.Megiddo=WAREHOUSE:New(STATIC:FindByName("Megiddo Warehouse"))
warehouse.Mezzeh=WAREHOUSE:New(STATIC:FindByName("Mezzeh Warehouse"))
warehouse.Minakh=WAREHOUSE:New(STATIC:FindByName("Minakh Warehouse"))
warehouse.Palmyra=WAREHOUSE:New(STATIC:FindByName("Palmyra Warehouse"))
warehouse.QabrasSitt=WAREHOUSE:New(STATIC:FindByName("Qabr as Sitt Warehouse"))
warehouse.RamatDavid=WAREHOUSE:New(STATIC:FindByName("Ramat David Warehouse"))
warehouse.Rayak=WAREHOUSE:New(STATIC:FindByName("Rayak Warehouse"))
warehouse.ReneMouawad=WAREHOUSE:New(STATIC:FindByName("Rene Mouawad Warehouse"))
warehouse.Tabqa=WAREHOUSE:New(STATIC:FindByName("Tabqa Warehouse"))
warehouse.Taftanaz=WAREHOUSE:New(STATIC:FindByName("Taftanaz Warehouse"))
warehouse.WujahAlHajar=WAREHOUSE:New(STATIC:FindByName("Wujah Al Hajar Warehouse"))


----If previous file exists it will load last saved warehouse
if file_exists("WarehouseAleppo") then --Script has been run before, so we need to load the save
  env.info("Existing warehouse, loading from File.")
  warehouse.AbualDuhur:Load(nil,"WarehouseAbualDuhur")
  warehouse.AdanaSakirpasa:Load(nil,"WarehouseAdanaSakirpasa")
  warehouse.AlDumayr:Load(nil,"WarehouseAlDumayr")
  warehouse.Aleppo:Load(nil,"WarehouseAleppo")
  warehouse.AlQusayr:Load(nil,"WarehouseAlQusayr")
  warehouse.AnNasiriyah:Load(nil,"WarehouseAnNasiriyah")
  warehouse.BasselAlAssad:Load(nil,"WarehouseBasselAlAssad")
  warehouse.BeirutRaficHariri:Load(nil,"WarehouseBeirutRaficHariri")
  warehouse.Damascus:Load(nil,"WarehouseDamascus")
  warehouse.EynShemer:Load(nil,"WarehouseEynShemer")
  warehouse.Haifa:Load(nil,"WarehouseHaifa")
  warehouse.Hama:Load(nil,"WarehouseHama")
  warehouse.Hatay:Load(nil,"WarehouseHatay")
  warehouse.Incirlik:Load(nil,"WarehouseIncirlik")
  warehouse.Jirah:Load(nil,"WarehouseJirah")
  warehouse.Khalkhalah:Load(nil,"WarehouseKhalkhalah")
  warehouse.KingHusseinAirCollege:Load(nil,"WarehouseKingHusseinAirCollege")
  warehouse.KiryatShmona:Load(nil,"WarehouseKiryatShmona")
  warehouse.Kuweires:Load(nil,"WarehouseKuweires")
  warehouse.MarjasSultanNorth:Load(nil,"WarehouseMarjasSultanNorth")
  warehouse.MarjasSultanSouth:Load(nil,"WarehouseMarjasSultanSouth")
  warehouse.MarjRuhayyil:Load(nil,"WarehouseMarjRuhayyil")
  warehouse.Megiddo:Load(nil,"WarehouseMegiddo")
  warehouse.Mezzeh:Load(nil,"WarehouseMezzeh")
  warehouse.Minakh:Load(nil,"WarehouseMinakh")
  warehouse.Palmyra:Load(nil,"WarehousePalmyra")
  warehouse.QabrasSitt:Load(nil,"WarehouseQabrasSitt")
  warehouse.RamatDavid:Load(nil,"WarehouseRamatDavid")
  warehouse.Rayak:Load(nil,"WarehouseRayak")
  warehouse.ReneMouawad:Load(nil,"WarehouseReneMouawad")
  warehouse.Tabqa:Load(nil,"WarehouseTabqa")
  warehouse.Taftanaz:Load(nil,"WarehouseTaftanaz")
  warehouse.WujahAlHajar:Load(nil,"WarehouseWujahAlHajar")
  --Starts the warehouses after load
  warehouse.AbualDuhur:Start()
  warehouse.AbualDuhur:SetRespawnAfterDestroyed(1800)
  warehouse.AdanaSakirpasa:Start()
  warehouse.AdanaSakirpasa:SetRespawnAfterDestroyed(1800)
  warehouse.AlDumayr:Start()
  warehouse.AlDumayr:SetRespawnAfterDestroyed(1800)
  warehouse.Aleppo:Start()
  warehouse.Aleppo:SetRespawnAfterDestroyed(1800)
  warehouse.AlQusayr:Start()
  warehouse.AlQusayr:SetRespawnAfterDestroyed(1800)
  warehouse.AnNasiriyah:Start()
  warehouse.AnNasiriyah:SetRespawnAfterDestroyed(1800)
  warehouse.BasselAlAssad:Start()
  warehouse.BasselAlAssad:SetRespawnAfterDestroyed(1800)
  warehouse.BeirutRaficHariri:Start()
  warehouse.BeirutRaficHariri:SetRespawnAfterDestroyed(1800)
  warehouse.Damascus:Start()
  warehouse.Damascus:SetRespawnAfterDestroyed(1800)
  warehouse.EynShemer:Start()
  warehouse.EynShemer:SetRespawnAfterDestroyed(1800)
  warehouse.Haifa:Start()
  warehouse.Haifa:SetRespawnAfterDestroyed(1800)
  warehouse.Hama:Start()
  warehouse.Hama:SetRespawnAfterDestroyed(1800)
  warehouse.Hatay:Start()
  warehouse.Hatay:SetRespawnAfterDestroyed(1800)
  warehouse.Incirlik:Start()
  warehouse.Incirlik:SetRespawnAfterDestroyed(1800)
  warehouse.Jirah:Start()
  warehouse.Jirah:SetRespawnAfterDestroyed(1800)
  warehouse.Khalkhalah:Start()
  warehouse.Khalkhalah:SetRespawnAfterDestroyed(1800)
  warehouse.KingHusseinAirCollege:Start()
  warehouse.KingHusseinAirCollege:SetRespawnAfterDestroyed(1800)
  warehouse.KiryatShmona:Start()
  warehouse.KiryatShmona:SetRespawnAfterDestroyed(1800)
  warehouse.Kuweires:Start()
  warehouse.Kuweires:SetRespawnAfterDestroyed(1800)
  warehouse.MarjasSultanNorth:Start()
  warehouse.MarjasSultanNorth:SetRespawnAfterDestroyed(1800)
  warehouse.MarjasSultanSouth:Start()
  warehouse.MarjasSultanSouth:SetRespawnAfterDestroyed(1800)
  warehouse.MarjRuhayyil:Start()
  warehouse.MarjRuhayyil:SetRespawnAfterDestroyed(1800)
  warehouse.Megiddo:Start()
  warehouse.Megiddo:SetRespawnAfterDestroyed(1800)
  warehouse.Mezzeh:Start()
  warehouse.Mezzeh:SetRespawnAfterDestroyed(1800)
  warehouse.Minakh:Start()
  warehouse.Minakh:SetRespawnAfterDestroyed(1800)
  warehouse.Palmyra:Start()
  warehouse.Palmyra:SetRespawnAfterDestroyed(1800)
  warehouse.QabrasSitt:Start()
  warehouse.QabrasSitt:SetRespawnAfterDestroyed(1800)
  warehouse.RamatDavid:Start()
  warehouse.RamatDavid:SetRespawnAfterDestroyed(1800)
  warehouse.Rayak:Start()
  warehouse.Rayak:SetRespawnAfterDestroyed(1800)
  warehouse.ReneMouawad:Start()
  warehouse.ReneMouawad:SetRespawnAfterDestroyed(1800)
  warehouse.Tabqa:Start()
  warehouse.Tabqa:SetRespawnAfterDestroyed(1800)
  warehouse.Taftanaz:Start()
  warehouse.Taftanaz:SetRespawnAfterDestroyed(1800)
  warehouse.WujahAlHajar:Start()
  warehouse.WujahAlHajar:SetRespawnAfterDestroyed(1800)
  else  
  --Fresh Campaign starts warehouses, and loads assets
  warehouse.AbualDuhur:Start()
  warehouse.AbualDuhur:SetRespawnAfterDestroyed(1800)
  warehouse.AdanaSakirpasa:Start()
  warehouse.AdanaSakirpasa:SetRespawnAfterDestroyed(1800)
  warehouse.AlDumayr:Start()
  warehouse.AlDumayr:SetRespawnAfterDestroyed(1800)
  warehouse.Aleppo:Start()
  warehouse.Aleppo:SetRespawnAfterDestroyed(1800)
  warehouse.AlQusayr:Start()
  warehouse.AlQusayr:SetRespawnAfterDestroyed(1800)
  warehouse.AnNasiriyah:Start()
  warehouse.AnNasiriyah:SetRespawnAfterDestroyed(1800)
  warehouse.BasselAlAssad:Start()
  warehouse.BasselAlAssad:SetRespawnAfterDestroyed(1800)
  warehouse.BeirutRaficHariri:Start()
  warehouse.BeirutRaficHariri:SetRespawnAfterDestroyed(1800)
  warehouse.Damascus:Start()
  warehouse.Damascus:SetRespawnAfterDestroyed(1800)
  warehouse.EynShemer:Start()
  warehouse.EynShemer:SetRespawnAfterDestroyed(1800)
  warehouse.Haifa:Start()
  warehouse.Haifa:SetRespawnAfterDestroyed(1800)
  warehouse.Hama:Start()
  warehouse.Hama:SetRespawnAfterDestroyed(1800)
  warehouse.Hatay:Start()
  warehouse.Hatay:SetRespawnAfterDestroyed(1800)
  warehouse.Incirlik:Start()
  warehouse.Incirlik:SetRespawnAfterDestroyed(1800)
  warehouse.Jirah:Start()
  warehouse.Jirah:SetRespawnAfterDestroyed(1800)
  warehouse.Khalkhalah:Start()
  warehouse.Khalkhalah:SetRespawnAfterDestroyed(1800)
  warehouse.KingHusseinAirCollege:Start()
  warehouse.KingHusseinAirCollege:SetRespawnAfterDestroyed(1800)
  warehouse.KiryatShmona:Start()
  warehouse.KiryatShmona:SetRespawnAfterDestroyed(1800)
  warehouse.Kuweires:Start()
  warehouse.Kuweires:SetRespawnAfterDestroyed(1800)
  warehouse.MarjasSultanNorth:Start()
  warehouse.MarjasSultanNorth:SetRespawnAfterDestroyed(1800)
  warehouse.MarjasSultanSouth:Start()
  warehouse.MarjasSultanSouth:SetRespawnAfterDestroyed(1800)
  warehouse.MarjRuhayyil:Start()
  warehouse.MarjRuhayyil:SetRespawnAfterDestroyed(1800)
  warehouse.Megiddo:Start()
  warehouse.Megiddo:SetRespawnAfterDestroyed(1800)
  warehouse.Mezzeh:Start()
  warehouse.Mezzeh:SetRespawnAfterDestroyed(1800)
  warehouse.Minakh:Start()
  warehouse.Minakh:SetRespawnAfterDestroyed(1800)
  warehouse.Palmyra:Start()
  warehouse.Palmyra:SetRespawnAfterDestroyed(1800)
  warehouse.QabrasSitt:Start()
  warehouse.QabrasSitt:SetRespawnAfterDestroyed(1800)
  warehouse.RamatDavid:Start()
  warehouse.RamatDavid:SetRespawnAfterDestroyed(1800)
  warehouse.Rayak:Start()
  warehouse.Rayak:SetRespawnAfterDestroyed(1800)
  warehouse.ReneMouawad:Start()
  warehouse.ReneMouawad:SetRespawnAfterDestroyed(1800)
  warehouse.Tabqa:Start()
  warehouse.Tabqa:SetRespawnAfterDestroyed(1800)
  warehouse.Taftanaz:Start()
  warehouse.Taftanaz:SetRespawnAfterDestroyed(1800)
  warehouse.WujahAlHajar:Start()
  warehouse.WujahAlHajar:SetRespawnAfterDestroyed(1800)
  ----Add Assets to the warehouses on new campaign
    --EXAMPLE*** WAREHOUSE:AddAsset(group, ngroups, forceattribute, forcecargobay, forceweight, loadradius, skill, liveries,    assignment) 
  warehouse.AbualDuhur:AddAsset("Resupply MBT T72B", 30)    --counted as tank  in stock
  warehouse.AbualDuhur:AddAsset("Resupply IFV BMP-3", 20)   --counted as APC in stock
  warehouse.AbualDuhur:AddAsset("Resupply AAA Shilka", 40)  --counted as AAA in stock
  warehouse.AbualDuhur:AddAsset("Resupply SAM SA-13", 40)   --Counted as SAM in stock
  warehouse.AbualDuhur:AddAsset("Resupply SAM SA-11", 20)   --Counted as SAM in stock
  warehouse.AbualDuhur:AddAsset("Resupply MBT Merkava", 30) --Counted as tank  in stock
  warehouse.AbualDuhur:AddAsset("Resupply IFV M2A1", 20)    --Counted as APC in stock
  warehouse.AbualDuhur:AddAsset("Resupply AAA Vulcan", 40)  --counted as AAA in stock
  warehouse.AbualDuhur:AddAsset("Resupply SAM Avenger", 40) --Counted as SAM in stock
  warehouse.AbualDuhur:AddAsset("Resupply SAM Hawk", 20)    --Counted as SAM in stock
  --warehouse.AbualDuhur:AddAsset("Red C-130", 2, nil, 1777000, nil, 10000)  
  warehouse.AdanaSakirpasa:AddAsset("Resupply MBT T72B", 30)    --counted as tank  in stock
  warehouse.AdanaSakirpasa:AddAsset("Resupply IFV BMP-3", 20)   --counted as APC in stock
  warehouse.AdanaSakirpasa:AddAsset("Resupply AAA Shilka", 40)  --counted as AAA in stock
  warehouse.AdanaSakirpasa:AddAsset("Resupply SAM SA-13", 40)   --Counted as SAM in stock
  warehouse.AdanaSakirpasa:AddAsset("Resupply SAM SA-11", 20)   --Counted as SAM in stock
  warehouse.AdanaSakirpasa:AddAsset("Resupply MBT Merkava", 30) --Counted as tank  in stock
  warehouse.AdanaSakirpasa:AddAsset("Resupply IFV M2A1", 20)    --Counted as APC in stock
  warehouse.AdanaSakirpasa:AddAsset("Resupply AAA Vulcan", 40)  --counted as AAA in stock
  warehouse.AdanaSakirpasa:AddAsset("Resupply SAM Avenger", 40) --Counted as SAM in stock
  warehouse.AdanaSakirpasa:AddAsset("Resupply SAM Hawk", 20)    --Counted as SAM in stock
  --warehouse.AdanaSakirpasa:AddAsset("Red C-130", 2, nil, 1777000, nil, 10000)  
  warehouse.AlDumayr:AddAsset("Resupply MBT T72B", 30)    --counted as tank  in stock
  warehouse.AlDumayr:AddAsset("Resupply IFV BMP-3", 20)   --counted as APC in stock
  warehouse.AlDumayr:AddAsset("Resupply AAA Shilka", 40)  --counted as AAA in stock
  warehouse.AlDumayr:AddAsset("Resupply SAM SA-13", 40)   --Counted as SAM in stock
  warehouse.AlDumayr:AddAsset("Resupply SAM SA-11", 20)   --Counted as SAM in stock
  warehouse.AlDumayr:AddAsset("Resupply MBT Merkava", 30) --Counted as tank  in stock
  warehouse.AlDumayr:AddAsset("Resupply IFV M2A1", 20)    --Counted as APC in stock
  warehouse.AlDumayr:AddAsset("Resupply AAA Vulcan", 40)  --counted as AAA in stock
  warehouse.AlDumayr:AddAsset("Resupply SAM Avenger", 40) --Counted as SAM in stock
  warehouse.AlDumayr:AddAsset("Resupply SAM Hawk", 20)    --Counted as SAM in stock
  --warehouse.AlDumayr:AddAsset("Red C-130", 2, nil, 1777000, nil, 10000)
  warehouse.Aleppo:AddAsset("Resupply MBT T72B", 30)    --counted as tank  in stock
  warehouse.Aleppo:AddAsset("Resupply IFV BMP-3", 20)   --counted as APC in stock
  warehouse.Aleppo:AddAsset("Resupply AAA Shilka", 40)  --counted as AAA in stock
  warehouse.Aleppo:AddAsset("Resupply SAM SA-13", 40)   --Counted as SAM in stock
  warehouse.Aleppo:AddAsset("Resupply SAM SA-11", 20)   --Counted as SAM in stock
  warehouse.Aleppo:AddAsset("Resupply MBT Merkava", 30) --Counted as tank  in stock
  warehouse.Aleppo:AddAsset("Resupply IFV M2A1", 20)    --Counted as APC in stock
  warehouse.Aleppo:AddAsset("Resupply AAA Vulcan", 40)  --counted as AAA in stock
  warehouse.Aleppo:AddAsset("Resupply SAM Avenger", 40) --Counted as SAM in stock
  warehouse.Aleppo:AddAsset("Resupply SAM Hawk", 20)    --Counted as SAM in stock
  --warehouse.Aleppo:AddAsset("Red C-130", 2, nil, 1777000, nil, 10000)
  warehouse.AlQusayr:AddAsset("Resupply MBT T72B", 30)    --counted as tank  in stock
  warehouse.AlQusayr:AddAsset("Resupply IFV BMP-3", 20)   --counted as APC in stock
  warehouse.AlQusayr:AddAsset("Resupply AAA Shilka", 40)  --counted as AAA in stock
  warehouse.AlQusayr:AddAsset("Resupply SAM SA-13", 40)   --Counted as SAM in stock
  warehouse.AlQusayr:AddAsset("Resupply SAM SA-11", 20)   --Counted as SAM in stock
  warehouse.AlQusayr:AddAsset("Resupply MBT Merkava", 30) --Counted as tank  in stock
  warehouse.AlQusayr:AddAsset("Resupply IFV M2A1", 20)    --Counted as APC in stock
  warehouse.AlQusayr:AddAsset("Resupply AAA Vulcan", 40)  --counted as AAA in stock
  warehouse.AlQusayr:AddAsset("Resupply SAM Avenger", 40) --Counted as SAM in stock
  warehouse.AlQusayr:AddAsset("Resupply SAM Hawk", 20)    --Counted as SAM in stock
  --warehouse.AlQusayr:AddAsset("Red C-130", 2, nil, 1777000, nil, 10000)
  warehouse.AnNasiriyah:AddAsset("Resupply MBT T72B", 30)    --counted as tank  in stock
  warehouse.AnNasiriyah:AddAsset("Resupply IFV BMP-3", 20)   --counted as APC in stock
  warehouse.AnNasiriyah:AddAsset("Resupply AAA Shilka", 40)  --counted as AAA in stock
  warehouse.AnNasiriyah:AddAsset("Resupply SAM SA-13", 40)   --Counted as SAM in stock
  warehouse.AnNasiriyah:AddAsset("Resupply SAM SA-11", 20)   --Counted as SAM in stock
  warehouse.AnNasiriyah:AddAsset("Resupply MBT Merkava", 30) --Counted as tank  in stock
  warehouse.AnNasiriyah:AddAsset("Resupply IFV M2A1", 20)    --Counted as APC in stock
  warehouse.AnNasiriyah:AddAsset("Resupply AAA Vulcan", 40)  --counted as AAA in stock
  warehouse.AnNasiriyah:AddAsset("Resupply SAM Avenger", 40) --Counted as SAM in stock
  warehouse.AnNasiriyah:AddAsset("Resupply SAM Hawk", 20)    --Counted as SAM in stock
  --warehouse.AnNasiriyah:AddAsset("Red C-130", 2, nil, 1777000, nil, 10000)
  warehouse.BasselAlAssad:AddAsset("Resupply MBT T72B", 30)    --counted as tank  in stock
  warehouse.BasselAlAssad:AddAsset("Resupply IFV BMP-3", 20)   --counted as APC in stock
  warehouse.BasselAlAssad:AddAsset("Resupply AAA Shilka", 40)  --counted as AAA in stock
  warehouse.BasselAlAssad:AddAsset("Resupply SAM SA-13", 40)   --Counted as SAM in stock
  warehouse.BasselAlAssad:AddAsset("Resupply SAM SA-11", 20)   --Counted as SAM in stock
  warehouse.BasselAlAssad:AddAsset("Resupply MBT Merkava", 30) --Counted as tank  in stock
  warehouse.BasselAlAssad:AddAsset("Resupply IFV M2A1", 20)    --Counted as APC in stock
  warehouse.BasselAlAssad:AddAsset("Resupply AAA Vulcan", 40)  --counted as AAA in stock
  warehouse.BasselAlAssad:AddAsset("Resupply SAM Avenger", 40) --Counted as SAM in stock
  warehouse.BasselAlAssad:AddAsset("Resupply SAM Hawk", 20)    --Counted as SAM in stock
  --warehouse.BasselAlAssad:AddAsset("Red C-130", 2, nil, 1777000, nil, 10000)
  warehouse.BeirutRaficHariri:AddAsset("Resupply MBT T72B", 30)    --counted as tank  in stock
  warehouse.BeirutRaficHariri:AddAsset("Resupply IFV BMP-3", 20)   --counted as APC in stock
  warehouse.BeirutRaficHariri:AddAsset("Resupply AAA Shilka", 40)  --counted as AAA in stock
  warehouse.BeirutRaficHariri:AddAsset("Resupply SAM SA-13", 40)   --Counted as SAM in stock
  warehouse.BeirutRaficHariri:AddAsset("Resupply SAM SA-11", 20)   --Counted as SAM in stock
  warehouse.BeirutRaficHariri:AddAsset("Resupply MBT Merkava", 30) --Counted as tank  in stock
  warehouse.BeirutRaficHariri:AddAsset("Resupply IFV M2A1", 20)    --Counted as APC in stock
  warehouse.BeirutRaficHariri:AddAsset("Resupply AAA Vulcan", 40)  --counted as AAA in stock
  warehouse.BeirutRaficHariri:AddAsset("Resupply SAM Avenger", 40) --Counted as SAM in stock
  warehouse.BeirutRaficHariri:AddAsset("Resupply SAM Hawk", 20)    --Counted as SAM in stock
  --warehouse.BeirutRaficHariri:AddAsset("Red C-130", 2, nil, 1777000, nil, 10000)
  warehouse.Damascus:AddAsset("Resupply MBT T72B", 30)    --counted as tank  in stock
  warehouse.Damascus:AddAsset("Resupply IFV BMP-3", 20)   --counted as APC in stock
  warehouse.Damascus:AddAsset("Resupply AAA Shilka", 40)  --counted as AAA in stock
  warehouse.Damascus:AddAsset("Resupply SAM SA-13", 40)   --Counted as SAM in stock
  warehouse.Damascus:AddAsset("Resupply SAM SA-11", 20)   --Counted as SAM in stock
  warehouse.Damascus:AddAsset("Resupply MBT Merkava", 30) --Counted as tank  in stock
  warehouse.Damascus:AddAsset("Resupply IFV M2A1", 20)    --Counted as APC in stock
  warehouse.Damascus:AddAsset("Resupply AAA Vulcan", 40)  --counted as AAA in stock
  warehouse.Damascus:AddAsset("Resupply SAM Avenger", 40) --Counted as SAM in stock
  warehouse.Damascus:AddAsset("Resupply SAM Hawk", 20)    --Counted as SAM in stock
  --warehouse.Damascus:AddAsset("Red C-130", 2, nil, 1777000, nil, 10000)
  warehouse.EynShemer:AddAsset("Resupply MBT T72B", 30)    --counted as tank  in stock
  warehouse.EynShemer:AddAsset("Resupply IFV BMP-3", 20)   --counted as APC in stock
  warehouse.EynShemer:AddAsset("Resupply AAA Shilka", 40)  --counted as AAA in stock
  warehouse.EynShemer:AddAsset("Resupply SAM SA-13", 40)   --Counted as SAM in stock
  warehouse.EynShemer:AddAsset("Resupply SAM SA-11", 20)   --Counted as SAM in stock
  warehouse.EynShemer:AddAsset("Resupply MBT Merkava", 30) --Counted as tank  in stock
  warehouse.EynShemer:AddAsset("Resupply IFV M2A1", 20)    --Counted as APC in stock
  warehouse.EynShemer:AddAsset("Resupply AAA Vulcan", 40)  --counted as AAA in stock
  warehouse.EynShemer:AddAsset("Resupply SAM Avenger", 40) --Counted as SAM in stock
  warehouse.EynShemer:AddAsset("Resupply SAM Hawk", 20)    --Counted as SAM in stock
  --warehouse.EynShemer:AddAsset("Red C-130", 2, nil, 1777000, nil, 10000)
  warehouse.Haifa:AddAsset("Resupply MBT T72B", 30)    --counted as tank  in stock
  warehouse.Haifa:AddAsset("Resupply IFV BMP-3", 20)   --counted as APC in stock
  warehouse.Haifa:AddAsset("Resupply AAA Shilka", 40)  --counted as AAA in stock
  warehouse.Haifa:AddAsset("Resupply SAM SA-13", 40)   --Counted as SAM in stock
  warehouse.Haifa:AddAsset("Resupply SAM SA-11", 20)   --Counted as SAM in stock
  warehouse.Haifa:AddAsset("Resupply MBT Merkava", 30) --Counted as tank  in stock
  warehouse.Haifa:AddAsset("Resupply IFV M2A1", 20)    --Counted as APC in stock
  warehouse.Haifa:AddAsset("Resupply AAA Vulcan", 40)  --counted as AAA in stock
  warehouse.Haifa:AddAsset("Resupply SAM Avenger", 40) --Counted as SAM in stock
  warehouse.Haifa:AddAsset("Resupply SAM Hawk", 20)    --Counted as SAM in stock
  --warehouse.Haifa:AddAsset("Red C-130", 2, nil, 1777000, nil, 10000)
  warehouse.Hama:AddAsset("Resupply MBT T72B", 30)    --counted as tank  in stock
  warehouse.Hama:AddAsset("Resupply IFV BMP-3", 20)   --counted as APC in stock
  warehouse.Hama:AddAsset("Resupply AAA Shilka", 40)  --counted as AAA in stock
  warehouse.Hama:AddAsset("Resupply SAM SA-13", 40)   --Counted as SAM in stock
  warehouse.Hama:AddAsset("Resupply SAM SA-11", 20)   --Counted as SAM in stock
  warehouse.Hama:AddAsset("Resupply MBT Merkava", 30) --Counted as tank  in stock
  warehouse.Hama:AddAsset("Resupply IFV M2A1", 20)    --Counted as APC in stock
  warehouse.Hama:AddAsset("Resupply AAA Vulcan", 40)  --counted as AAA in stock
  warehouse.Hama:AddAsset("Resupply SAM Avenger", 40) --Counted as SAM in stock
  warehouse.Hama:AddAsset("Resupply SAM Hawk", 20)    --Counted as SAM in stock
  --warehouse.Hama:AddAsset("Red C-130", 2, nil, 1777000, nil, 10000)
  warehouse.Hatay:AddAsset("Resupply MBT T72B", 30)    --counted as tank  in stock
  warehouse.Hatay:AddAsset("Resupply IFV BMP-3", 20)   --counted as APC in stock
  warehouse.Hatay:AddAsset("Resupply AAA Shilka", 40)  --counted as AAA in stock
  warehouse.Hatay:AddAsset("Resupply SAM SA-13", 40)   --Counted as SAM in stock
  warehouse.Hatay:AddAsset("Resupply SAM SA-11", 20)   --Counted as SAM in stock
  warehouse.Hatay:AddAsset("Resupply MBT Merkava", 30) --Counted as tank  in stock
  warehouse.Hatay:AddAsset("Resupply IFV M2A1", 20)    --Counted as APC in stock
  warehouse.Hatay:AddAsset("Resupply AAA Vulcan", 40)  --counted as AAA in stock
  warehouse.Hatay:AddAsset("Resupply SAM Avenger", 40) --Counted as SAM in stock
  warehouse.Hatay:AddAsset("Resupply SAM Hawk", 20)    --Counted as SAM in stock
  --warehouse.Hatay:AddAsset("Red C-130", 2, nil, 1777000, nil, 10000)
  warehouse.Incirlik:AddAsset("Resupply MBT T72B", 30)    --counted as tank  in stock
  warehouse.Incirlik:AddAsset("Resupply IFV BMP-3", 20)   --counted as APC in stock
  warehouse.Incirlik:AddAsset("Resupply AAA Shilka", 40)  --counted as AAA in stock
  warehouse.Incirlik:AddAsset("Resupply SAM SA-13", 40)   --Counted as SAM in stock
  warehouse.Incirlik:AddAsset("Resupply SAM SA-11", 20)   --Counted as SAM in stock
  warehouse.Incirlik:AddAsset("Resupply MBT Merkava", 30) --Counted as tank  in stock
  warehouse.Incirlik:AddAsset("Resupply IFV M2A1", 20)    --Counted as APC in stock
  warehouse.Incirlik:AddAsset("Resupply AAA Vulcan", 40)  --counted as AAA in stock
  warehouse.Incirlik:AddAsset("Resupply SAM Avenger", 40) --Counted as SAM in stock
  warehouse.Incirlik:AddAsset("Resupply SAM Hawk", 20)    --Counted as SAM in stock
  --warehouse.Incirlik:AddAsset("Red C-130", 2, nil, 1777000, nil, 10000)
  warehouse.Jirah:AddAsset("Resupply MBT T72B", 30)    --counted as tank  in stock
  warehouse.Jirah:AddAsset("Resupply IFV BMP-3", 20)   --counted as APC in stock
  warehouse.Jirah:AddAsset("Resupply AAA Shilka", 40)  --counted as AAA in stock
  warehouse.Jirah:AddAsset("Resupply SAM SA-13", 40)   --Counted as SAM in stock
  warehouse.Jirah:AddAsset("Resupply SAM SA-11", 20)   --Counted as SAM in stock
  warehouse.Jirah:AddAsset("Resupply MBT Merkava", 30) --Counted as tank  in stock
  warehouse.Jirah:AddAsset("Resupply IFV M2A1", 20)    --Counted as APC in stock
  warehouse.Jirah:AddAsset("Resupply AAA Vulcan", 40)  --counted as AAA in stock
  warehouse.Jirah:AddAsset("Resupply SAM Avenger", 40) --Counted as SAM in stock
  warehouse.Jirah:AddAsset("Resupply SAM Hawk", 20)    --Counted as SAM in stock
  --warehouse.Jirah:AddAsset("Red C-130", 2, nil, 1777000, nil, 10000)
  warehouse.Khalkhalah:AddAsset("Resupply MBT T72B", 30)    --counted as tank  in stock
  warehouse.Khalkhalah:AddAsset("Resupply IFV BMP-3", 20)   --counted as APC in stock
  warehouse.Khalkhalah:AddAsset("Resupply AAA Shilka", 40)  --counted as AAA in stock
  warehouse.Khalkhalah:AddAsset("Resupply SAM SA-13", 40)   --Counted as SAM in stock
  warehouse.Khalkhalah:AddAsset("Resupply SAM SA-11", 20)   --Counted as SAM in stock
  warehouse.Khalkhalah:AddAsset("Resupply MBT Merkava", 30) --Counted as tank  in stock
  warehouse.Khalkhalah:AddAsset("Resupply IFV M2A1", 20)    --Counted as APC in stock
  warehouse.Khalkhalah:AddAsset("Resupply AAA Vulcan", 40)  --counted as AAA in stock
  warehouse.Khalkhalah:AddAsset("Resupply SAM Avenger", 40) --Counted as SAM in stock
  warehouse.Khalkhalah:AddAsset("Resupply SAM Hawk", 20)    --Counted as SAM in stock
  --warehouse.Khalkhalah:AddAsset("Red C-130", 2, nil, 1777000, nil, 10000)
  warehouse.KingHusseinAirCollege:AddAsset("Resupply MBT T72B", 30)    --counted as tank  in stock
  warehouse.KingHusseinAirCollege:AddAsset("Resupply IFV BMP-3", 20)   --counted as APC in stock
  warehouse.KingHusseinAirCollege:AddAsset("Resupply AAA Shilka", 40)  --counted as AAA in stock
  warehouse.KingHusseinAirCollege:AddAsset("Resupply SAM SA-13", 40)   --Counted as SAM in stock
  warehouse.KingHusseinAirCollege:AddAsset("Resupply SAM SA-11", 20)   --Counted as SAM in stock
  warehouse.KingHusseinAirCollege:AddAsset("Resupply MBT Merkava", 30) --Counted as tank  in stock
  warehouse.KingHusseinAirCollege:AddAsset("Resupply IFV M2A1", 20)    --Counted as APC in stock
  warehouse.KingHusseinAirCollege:AddAsset("Resupply AAA Vulcan", 40)  --counted as AAA in stock
  warehouse.KingHusseinAirCollege:AddAsset("Resupply SAM Avenger", 40) --Counted as SAM in stock
  warehouse.KingHusseinAirCollege:AddAsset("Resupply SAM Hawk", 20)    --Counted as SAM in stock
  --warehouse.KingHusseinAirCollege:AddAsset("Red C-130", 2, nil, 1777000, nil, 10000)  warehouse.KiryatShmona
  warehouse.KiryatShmona:AddAsset("Resupply MBT T72B", 30)    --counted as tank  in stock
  warehouse.KiryatShmona:AddAsset("Resupply IFV BMP-3", 20)   --counted as APC in stock
  warehouse.KiryatShmona:AddAsset("Resupply AAA Shilka", 40)  --counted as AAA in stock
  warehouse.KiryatShmona:AddAsset("Resupply SAM SA-13", 40)   --Counted as SAM in stock
  warehouse.KiryatShmona:AddAsset("Resupply SAM SA-11", 20)   --Counted as SAM in stock
  warehouse.KiryatShmona:AddAsset("Resupply MBT Merkava", 30) --Counted as tank  in stock
  warehouse.KiryatShmona:AddAsset("Resupply IFV M2A1", 20)    --Counted as APC in stock
  warehouse.KiryatShmona:AddAsset("Resupply AAA Vulcan", 40)  --counted as AAA in stock
  warehouse.KiryatShmona:AddAsset("Resupply SAM Avenger", 40) --Counted as SAM in stock
  warehouse.KiryatShmona:AddAsset("Resupply SAM Hawk", 20)    --Counted as SAM in stock
  --warehouse.KiryatShmona:AddAsset("Red C-130", 2, nil, 1777000, nil, 10000)  warehouse.KiryatShmona
  warehouse.Kuweires:AddAsset("Resupply MBT T72B", 30)    --counted as tank  in stock
  warehouse.Kuweires:AddAsset("Resupply IFV BMP-3", 20)   --counted as APC in stock
  warehouse.Kuweires:AddAsset("Resupply AAA Shilka", 40)  --counted as AAA in stock
  warehouse.Kuweires:AddAsset("Resupply SAM SA-13", 40)   --Counted as SAM in stock
  warehouse.Kuweires:AddAsset("Resupply SAM SA-11", 20)   --Counted as SAM in stock
  warehouse.Kuweires:AddAsset("Resupply MBT Merkava", 30) --Counted as tank  in stock
  warehouse.Kuweires:AddAsset("Resupply IFV M2A1", 20)    --Counted as APC in stock
  warehouse.Kuweires:AddAsset("Resupply AAA Vulcan", 40)  --counted as AAA in stock
  warehouse.Kuweires:AddAsset("Resupply SAM Avenger", 40) --Counted as SAM in stock
  warehouse.Kuweires:AddAsset("Resupply SAM Hawk", 20)    --Counted as SAM in stock
  --warehouse.Kuweires:AddAsset("Red C-130", 2, nil, 1777000, nil, 10000)  warehouse.KiryatShmona
  warehouse.MarjasSultanNorth:AddAsset("Resupply MBT T72B", 30)    --counted as tank  in stock
  warehouse.MarjasSultanNorth:AddAsset("Resupply IFV BMP-3", 20)   --counted as APC in stock
  warehouse.MarjasSultanNorth:AddAsset("Resupply AAA Shilka", 40)  --counted as AAA in stock
  warehouse.MarjasSultanNorth:AddAsset("Resupply SAM SA-13", 40)   --Counted as SAM in stock
  warehouse.MarjasSultanNorth:AddAsset("Resupply SAM SA-11", 20)   --Counted as SAM in stock
  warehouse.MarjasSultanNorth:AddAsset("Resupply MBT Merkava", 30) --Counted as tank  in stock
  warehouse.MarjasSultanNorth:AddAsset("Resupply IFV M2A1", 20)    --Counted as APC in stock
  warehouse.MarjasSultanNorth:AddAsset("Resupply AAA Vulcan", 40)  --counted as AAA in stock
  warehouse.MarjasSultanNorth:AddAsset("Resupply SAM Avenger", 40) --Counted as SAM in stock
  warehouse.MarjasSultanNorth:AddAsset("Resupply SAM Hawk", 20)    --Counted as SAM in stock
  --warehouse.MarjasSultanNorth:AddAsset("Red C-130", 2, nil, 1777000, nil, 10000)  warehouse.KiryatShmona
  warehouse.MarjasSultanSouth:AddAsset("Resupply MBT T72B", 30)    --counted as tank  in stock
  warehouse.MarjasSultanSouth:AddAsset("Resupply IFV BMP-3", 20)   --counted as APC in stock
  warehouse.MarjasSultanSouth:AddAsset("Resupply AAA Shilka", 40)  --counted as AAA in stock
  warehouse.MarjasSultanSouth:AddAsset("Resupply SAM SA-13", 40)   --Counted as SAM in stock
  warehouse.MarjasSultanSouth:AddAsset("Resupply SAM SA-11", 20)   --Counted as SAM in stock
  warehouse.MarjasSultanSouth:AddAsset("Resupply MBT Merkava", 30) --Counted as tank  in stock
  warehouse.MarjasSultanSouth:AddAsset("Resupply IFV M2A1", 20)    --Counted as APC in stock
  warehouse.MarjasSultanSouth:AddAsset("Resupply AAA Vulcan", 40)  --counted as AAA in stock
  warehouse.MarjasSultanSouth:AddAsset("Resupply SAM Avenger", 40) --Counted as SAM in stock
  warehouse.MarjasSultanSouth:AddAsset("Resupply SAM Hawk", 20)    --Counted as SAM in stock
  --warehouse.MarjasSultanSouth:AddAsset("Red C-130", 2, nil, 1777000, nil, 10000)  warehouse.KiryatShmona
  warehouse.MarjRuhayyil:AddAsset("Resupply MBT T72B", 30)    --counted as tank  in stock
  warehouse.MarjRuhayyil:AddAsset("Resupply IFV BMP-3", 20)   --counted as APC in stock
  warehouse.MarjRuhayyil:AddAsset("Resupply AAA Shilka", 40)  --counted as AAA in stock
  warehouse.MarjRuhayyil:AddAsset("Resupply SAM SA-13", 40)   --Counted as SAM in stock
  warehouse.MarjRuhayyil:AddAsset("Resupply SAM SA-11", 20)   --Counted as SAM in stock
  warehouse.MarjRuhayyil:AddAsset("Resupply MBT Merkava", 30) --Counted as tank  in stock
  warehouse.MarjRuhayyil:AddAsset("Resupply IFV M2A1", 20)    --Counted as APC in stock
  warehouse.MarjRuhayyil:AddAsset("Resupply AAA Vulcan", 40)  --counted as AAA in stock
  warehouse.MarjRuhayyil:AddAsset("Resupply SAM Avenger", 40) --Counted as SAM in stock
  warehouse.MarjRuhayyil:AddAsset("Resupply SAM Hawk", 20)    --Counted as SAM in stock
  --warehouse.MarjRuhayyil:AddAsset("Red C-130", 2, nil, 1777000, nil, 10000)  warehouse.KiryatShmona
  warehouse.Megiddo:AddAsset("Resupply MBT T72B", 30)    --counted as tank  in stock
  warehouse.Megiddo:AddAsset("Resupply IFV BMP-3", 20)   --counted as APC in stock
  warehouse.Megiddo:AddAsset("Resupply AAA Shilka", 40)  --counted as AAA in stock
  warehouse.Megiddo:AddAsset("Resupply SAM SA-13", 40)   --Counted as SAM in stock
  warehouse.Megiddo:AddAsset("Resupply SAM SA-11", 20)   --Counted as SAM in stock
  warehouse.Megiddo:AddAsset("Resupply MBT Merkava", 30) --Counted as tank  in stock
  warehouse.Megiddo:AddAsset("Resupply IFV M2A1", 20)    --Counted as APC in stock
  warehouse.Megiddo:AddAsset("Resupply AAA Vulcan", 40)  --counted as AAA in stock
  warehouse.Megiddo:AddAsset("Resupply SAM Avenger", 40) --Counted as SAM in stock
  warehouse.Megiddo:AddAsset("Resupply SAM Hawk", 20)    --Counted as SAM in stock
  --warehouse.Megiddo:AddAsset("Red C-130", 2, nil, 1777000, nil, 10000)  warehouse.KiryatShmona
  warehouse.Mezzeh:AddAsset("Resupply MBT T72B", 30)    --counted as tank  in stock
  warehouse.Mezzeh:AddAsset("Resupply IFV BMP-3", 20)   --counted as APC in stock
  warehouse.Mezzeh:AddAsset("Resupply AAA Shilka", 40)  --counted as AAA in stock
  warehouse.Mezzeh:AddAsset("Resupply SAM SA-13", 40)   --Counted as SAM in stock
  warehouse.Mezzeh:AddAsset("Resupply SAM SA-11", 20)   --Counted as SAM in stock
  warehouse.Mezzeh:AddAsset("Resupply MBT Merkava", 30) --Counted as tank  in stock
  warehouse.Mezzeh:AddAsset("Resupply IFV M2A1", 20)    --Counted as APC in stock
  warehouse.Mezzeh:AddAsset("Resupply AAA Vulcan", 40)  --counted as AAA in stock
  warehouse.Mezzeh:AddAsset("Resupply SAM Avenger", 40) --Counted as SAM in stock
  warehouse.Mezzeh:AddAsset("Resupply SAM Hawk", 20)    --Counted as SAM in stock
  --warehouse.Mezzeh:AddAsset("Red C-130", 2, nil, 1777000, nil, 10000)  warehouse.KiryatShmona
  warehouse.Minakh:AddAsset("Resupply MBT T72B", 30)    --counted as tank  in stock
  warehouse.Minakh:AddAsset("Resupply IFV BMP-3", 20)   --counted as APC in stock
  warehouse.Minakh:AddAsset("Resupply AAA Shilka", 40)  --counted as AAA in stock
  warehouse.Minakh:AddAsset("Resupply SAM SA-13", 40)   --Counted as SAM in stock
  warehouse.Minakh:AddAsset("Resupply SAM SA-11", 20)   --Counted as SAM in stock
  warehouse.Minakh:AddAsset("Resupply MBT Merkava", 30) --Counted as tank  in stock
  warehouse.Minakh:AddAsset("Resupply IFV M2A1", 20)    --Counted as APC in stock
  warehouse.Minakh:AddAsset("Resupply AAA Vulcan", 40)  --counted as AAA in stock
  warehouse.Minakh:AddAsset("Resupply SAM Avenger", 40) --Counted as SAM in stock
  warehouse.Minakh:AddAsset("Resupply SAM Hawk", 20)    --Counted as SAM in stock
  --warehouse.Minakh:AddAsset("Red C-130", 2, nil, 1777000, nil, 10000)  warehouse.KiryatShmona
  warehouse.Palmyra:AddAsset("Resupply MBT T72B", 30)    --counted as tank  in stock
  warehouse.Palmyra:AddAsset("Resupply IFV BMP-3", 20)   --counted as APC in stock
  warehouse.Palmyra:AddAsset("Resupply AAA Shilka", 40)  --counted as AAA in stock
  warehouse.Palmyra:AddAsset("Resupply SAM SA-13", 40)   --Counted as SAM in stock
  warehouse.Palmyra:AddAsset("Resupply SAM SA-11", 20)   --Counted as SAM in stock
  warehouse.Palmyra:AddAsset("Resupply MBT Merkava", 30) --Counted as tank  in stock
  warehouse.Palmyra:AddAsset("Resupply IFV M2A1", 20)    --Counted as APC in stock
  warehouse.Palmyra:AddAsset("Resupply AAA Vulcan", 40)  --counted as AAA in stock
  warehouse.Palmyra:AddAsset("Resupply SAM Avenger", 40) --Counted as SAM in stock
  warehouse.Palmyra:AddAsset("Resupply SAM Hawk", 20)    --Counted as SAM in stock
  --warehouse.Palmyra:AddAsset("Red C-130", 2, nil, 1777000, nil, 10000)  warehouse.KiryatShmona
  warehouse.QabrasSitt:AddAsset("Resupply MBT T72B", 30)    --counted as tank  in stock
  warehouse.QabrasSitt:AddAsset("Resupply IFV BMP-3", 20)   --counted as APC in stock
  warehouse.QabrasSitt:AddAsset("Resupply AAA Shilka", 40)  --counted as AAA in stock
  warehouse.QabrasSitt:AddAsset("Resupply SAM SA-13", 40)   --Counted as SAM in stock
  warehouse.QabrasSitt:AddAsset("Resupply SAM SA-11", 20)   --Counted as SAM in stock
  warehouse.QabrasSitt:AddAsset("Resupply MBT Merkava", 30) --Counted as tank  in stock
  warehouse.QabrasSitt:AddAsset("Resupply IFV M2A1", 20)    --Counted as APC in stock
  warehouse.QabrasSitt:AddAsset("Resupply AAA Vulcan", 40)  --counted as AAA in stock
  warehouse.QabrasSitt:AddAsset("Resupply SAM Avenger", 40) --Counted as SAM in stock
  warehouse.QabrasSitt:AddAsset("Resupply SAM Hawk", 20)    --Counted as SAM in stock
  --warehouse.QabrasSitt:AddAsset("Red C-130", 2, nil, 1777000, nil, 10000)  warehouse.KiryatShmona
  warehouse.RamatDavid:AddAsset("Resupply MBT T72B", 30)    --counted as tank  in stock
  warehouse.RamatDavid:AddAsset("Resupply IFV BMP-3", 20)   --counted as APC in stock
  warehouse.RamatDavid:AddAsset("Resupply AAA Shilka", 40)  --counted as AAA in stock
  warehouse.RamatDavid:AddAsset("Resupply SAM SA-13", 40)   --Counted as SAM in stock
  warehouse.RamatDavid:AddAsset("Resupply SAM SA-11", 20)   --Counted as SAM in stock
  warehouse.RamatDavid:AddAsset("Resupply MBT Merkava", 30) --Counted as tank  in stock
  warehouse.RamatDavid:AddAsset("Resupply IFV M2A1", 20)    --Counted as APC in stock
  warehouse.RamatDavid:AddAsset("Resupply AAA Vulcan", 40)  --counted as AAA in stock
  warehouse.RamatDavid:AddAsset("Resupply SAM Avenger", 40) --Counted as SAM in stock
  warehouse.RamatDavid:AddAsset("Resupply SAM Hawk", 20)    --Counted as SAM in stock
  --warehouse.RamatDavid:AddAsset("Red C-130", 2, nil, 1777000, nil, 10000)  warehouse.KiryatShmona
  warehouse.Rayak:AddAsset("Resupply MBT T72B", 30)    --counted as tank  in stock
  warehouse.Rayak:AddAsset("Resupply IFV BMP-3", 20)   --counted as APC in stock
  warehouse.Rayak:AddAsset("Resupply AAA Shilka", 40)  --counted as AAA in stock
  warehouse.Rayak:AddAsset("Resupply SAM SA-13", 40)   --Counted as SAM in stock
  warehouse.Rayak:AddAsset("Resupply SAM SA-11", 20)   --Counted as SAM in stock
  warehouse.Rayak:AddAsset("Resupply MBT Merkava", 30) --Counted as tank  in stock
  warehouse.Rayak:AddAsset("Resupply IFV M2A1", 20)    --Counted as APC in stock
  warehouse.Rayak:AddAsset("Resupply AAA Vulcan", 40)  --counted as AAA in stock
  warehouse.Rayak:AddAsset("Resupply SAM Avenger", 40) --Counted as SAM in stock
  warehouse.Rayak:AddAsset("Resupply SAM Hawk", 20)    --Counted as SAM in stock
  --warehouse.Rayak:AddAsset("Red C-130", 2, nil, 1777000, nil, 10000)  warehouse.KiryatShmona
  warehouse.ReneMouawad:AddAsset("Resupply MBT T72B", 30)    --counted as tank  in stock
  warehouse.ReneMouawad:AddAsset("Resupply IFV BMP-3", 20)   --counted as APC in stock
  warehouse.ReneMouawad:AddAsset("Resupply AAA Shilka", 40)  --counted as AAA in stock
  warehouse.ReneMouawad:AddAsset("Resupply SAM SA-13", 40)   --Counted as SAM in stock
  warehouse.ReneMouawad:AddAsset("Resupply SAM SA-11", 20)   --Counted as SAM in stock
  warehouse.ReneMouawad:AddAsset("Resupply MBT Merkava", 30) --Counted as tank  in stock
  warehouse.ReneMouawad:AddAsset("Resupply IFV M2A1", 20)    --Counted as APC in stock
  warehouse.ReneMouawad:AddAsset("Resupply AAA Vulcan", 40)  --counted as AAA in stock
  warehouse.ReneMouawad:AddAsset("Resupply SAM Avenger", 40) --Counted as SAM in stock
  warehouse.ReneMouawad:AddAsset("Resupply SAM Hawk", 20)    --Counted as SAM in stock
  --warehouse.ReneMouawad:AddAsset("Red C-130", 2, nil, 1777000, nil, 10000)  warehouse.KiryatShmona
  warehouse.Tabqa:AddAsset("Resupply MBT T72B", 30)    --counted as tank  in stock
  warehouse.Tabqa:AddAsset("Resupply IFV BMP-3", 20)   --counted as APC in stock
  warehouse.Tabqa:AddAsset("Resupply AAA Shilka", 40)  --counted as AAA in stock
  warehouse.Tabqa:AddAsset("Resupply SAM SA-13", 40)   --Counted as SAM in stock
  warehouse.Tabqa:AddAsset("Resupply SAM SA-11", 20)   --Counted as SAM in stock
  warehouse.Tabqa:AddAsset("Resupply MBT Merkava", 30) --Counted as tank  in stock
  warehouse.Tabqa:AddAsset("Resupply IFV M2A1", 20)    --Counted as APC in stock
  warehouse.Tabqa:AddAsset("Resupply AAA Vulcan", 40)  --counted as AAA in stock
  warehouse.Tabqa:AddAsset("Resupply SAM Avenger", 40) --Counted as SAM in stock
  warehouse.Tabqa:AddAsset("Resupply SAM Hawk", 20)    --Counted as SAM in stock
  --warehouse.Tabqa:AddAsset("Red C-130", 2, nil, 1777000, nil, 10000)  warehouse.KiryatShmona
  warehouse.Taftanaz:AddAsset("Resupply MBT T72B", 30)    --counted as tank  in stock
  warehouse.Taftanaz:AddAsset("Resupply IFV BMP-3", 20)   --counted as APC in stock
  warehouse.Taftanaz:AddAsset("Resupply AAA Shilka", 40)  --counted as AAA in stock
  warehouse.Taftanaz:AddAsset("Resupply SAM SA-13", 40)   --Counted as SAM in stock
  warehouse.Taftanaz:AddAsset("Resupply SAM SA-11", 20)   --Counted as SAM in stock
  warehouse.Taftanaz:AddAsset("Resupply MBT Merkava", 30) --Counted as tank  in stock
  warehouse.Taftanaz:AddAsset("Resupply IFV M2A1", 20)    --Counted as APC in stock
  warehouse.Taftanaz:AddAsset("Resupply AAA Vulcan", 40)  --counted as AAA in stock
  warehouse.Taftanaz:AddAsset("Resupply SAM Avenger", 40) --Counted as SAM in stock
  warehouse.Taftanaz:AddAsset("Resupply SAM Hawk", 20)    --Counted as SAM in stock
  --warehouse.Taftanaz:AddAsset("Red C-130", 2, nil, 1777000, nil, 10000)  warehouse.KiryatShmona
  warehouse.WujahAlHajar:AddAsset("Resupply MBT T72B", 30)    --counted as tank  in stock
  warehouse.WujahAlHajar:AddAsset("Resupply IFV BMP-3", 20)   --counted as APC in stock
  warehouse.WujahAlHajar:AddAsset("Resupply AAA Shilka", 40)  --counted as AAA in stock
  warehouse.WujahAlHajar:AddAsset("Resupply SAM SA-13", 40)   --Counted as SAM in stock
  warehouse.WujahAlHajar:AddAsset("Resupply SAM SA-11", 20)   --Counted as SAM in stock
  warehouse.WujahAlHajar:AddAsset("Resupply MBT Merkava", 30) --Counted as tank  in stock
  warehouse.WujahAlHajar:AddAsset("Resupply IFV M2A1", 20)    --Counted as APC in stock
  warehouse.WujahAlHajar:AddAsset("Resupply AAA Vulcan", 40)  --counted as AAA in stock
  warehouse.WujahAlHajar:AddAsset("Resupply SAM Avenger", 40) --Counted as SAM in stock
  warehouse.WujahAlHajar:AddAsset("Resupply SAM Hawk", 20)    --Counted as SAM in stock
  --warehouse.WujahAlHajar:AddAsset("Red C-130", 2, nil, 1777000, nil, 10000)  warehouse.KiryatShmona
end

----Set Spawn Zones for the warehouses
warehouse.AbualDuhur:SetSpawnZone(ZONE_POLYGON:New("Abu al-Duhur Warehouse Spawn Zone #001", GROUP:FindByName("Abu al-Duhur Warehouse Spawn Zone #001")))
warehouse.AdanaSakirpasa:SetSpawnZone(ZONE_POLYGON:New("Adana Sakirpasa Warehouse Spawn Zone #001", GROUP:FindByName("Adana Sakirpasa Warehouse Spawn Zone #001")))
warehouse.AlDumayr:SetSpawnZone(ZONE_POLYGON:New("Al-Dumayr Warehouse Spawn Zone #001", GROUP:FindByName("Al-Dumayr Warehouse Spawn Zone #001")))
warehouse.Aleppo:SetSpawnZone(ZONE_POLYGON:New("Aleppo Warehouse Spawn Zone #001", GROUP:FindByName("Aleppo Warehouse Spawn Zone #001")))
warehouse.AlQusayr:SetSpawnZone(ZONE_POLYGON:New("Al Qusayr Warehouse Spawn Zone #001", GROUP:FindByName("Al Qusayr Warehouse Spawn Zone #001")))
warehouse.AnNasiriyah:SetSpawnZone(ZONE_POLYGON:New("An Nasiriyah Warehouse Spawn Zone #001", GROUP:FindByName("An Nasiriyah Warehouse Spawn Zone #001")))
warehouse.BasselAlAssad:SetSpawnZone(ZONE_POLYGON:New("Bassel Al-Assad Warehouse Spawn Zone #001", GROUP:FindByName("Bassel Al-Assad Warehouse Spawn Zone #001")))
warehouse.BeirutRaficHariri:SetSpawnZone(ZONE_POLYGON:New("Beirut-Rafic Hariri Warehouse Spawn Zone #001", GROUP:FindByName("Beirut-Rafic Hariri Warehouse Spawn Zone #001")))
warehouse.Damascus:SetSpawnZone(ZONE_POLYGON:New("Damascus Warehouse Spawn Zone #001", GROUP:FindByName("Damascus Warehouse Spawn Zone #001")))
warehouse.EynShemer:SetSpawnZone(ZONE_POLYGON:New("Eyn Shemer Warehouse Spawn Zone #001", GROUP:FindByName("Eyn Shemer Warehouse Spawn Zone #001")))
warehouse.Haifa:SetSpawnZone(ZONE_POLYGON:New("Haifa Warehouse Spawn Zone #001", GROUP:FindByName("Haifa Warehouse Spawn Zone #001")))
warehouse.Hama:SetSpawnZone(ZONE_POLYGON:New("Hama Warehouse Spawn Zone #001", GROUP:FindByName("Hama Warehouse Spawn Zone #001")))
warehouse.Hatay:SetSpawnZone(ZONE_POLYGON:New("Hatay Warehouse Spawn Zone #001", GROUP:FindByName("Hatay Warehouse Spawn Zone #001")))
warehouse.Incirlik:SetSpawnZone(ZONE_POLYGON:New("Incirlik Warehouse Spawn Zone #001", GROUP:FindByName("Incirlik Warehouse Spawn Zone #001")))
warehouse.Jirah:SetSpawnZone(ZONE_POLYGON:New("Jirah Warehouse Spawn Zone #001", GROUP:FindByName("Jirah Warehouse Spawn Zone #001")))
warehouse.Khalkhalah:SetSpawnZone(ZONE_POLYGON:New("Khalkhalah Warehouse Spawn Zone #001", GROUP:FindByName("Khalkhalah Warehouse Spawn Zone #001")))
warehouse.KingHusseinAirCollege:SetSpawnZone(ZONE_POLYGON:New("King Hussein Air College Warehouse Spawn Zone #001", GROUP:FindByName("King Hussein Air College Warehouse Spawn Zone #001")))
warehouse.KiryatShmona:SetSpawnZone(ZONE_POLYGON:New("Kiryat Shmona Warehouse Spawn Zone #001", GROUP:FindByName("Kiryat Shmona Warehouse Spawn Zone #001")))
warehouse.Kuweires:SetSpawnZone(ZONE_POLYGON:New("Kuweires Warehouse Spawn Zone #001", GROUP:FindByName("Kuweires Warehouse Spawn Zone #001")))
warehouse.MarjasSultanNorth:SetSpawnZone(ZONE_POLYGON:New("Marj as Sultan North Warehouse Spawn Zone #001", GROUP:FindByName("Marj as Sultan North Warehouse Spawn Zone #001")))
warehouse.MarjasSultanSouth:SetSpawnZone(ZONE_POLYGON:New("Marj as Sultan South Warehouse Spawn Zone #001", GROUP:FindByName("Marj as Sultan South Warehouse Spawn Zone #001")))
warehouse.MarjRuhayyil:SetSpawnZone(ZONE_POLYGON:New("Marj Ruhayyi Warehouse Spawn Zone #001", GROUP:FindByName("Marj Ruhayyi Warehouse Spawn Zone #001")))
warehouse.Megiddo:SetSpawnZone(ZONE_POLYGON:New("Megiddo Warehouse Spawn Zone #001", GROUP:FindByName("Megiddo Warehouse Spawn Zone #001")))
warehouse.Mezzeh:SetSpawnZone(ZONE_POLYGON:New("Mezzeh Warehouse Spawn Zone #001", GROUP:FindByName("Mezzeh Warehouse Spawn Zone #001")))
warehouse.Minakh:SetSpawnZone(ZONE_POLYGON:New("Minakh Warehouse Spawn Zone #001", GROUP:FindByName("Minakh Warehouse Spawn Zone #001")))
warehouse.Palmyra:SetSpawnZone(ZONE_POLYGON:New("Palmyra Warehouse Spawn Zone #001", GROUP:FindByName("Palmyra Warehouse Spawn Zone #001")))
warehouse.QabrasSitt:SetSpawnZone(ZONE_POLYGON:New("Qabr as Sitt Warehouse Spawn Zone #001", GROUP:FindByName("Qabr as Sitt Warehouse Spawn Zone #001")))
warehouse.RamatDavid:SetSpawnZone(ZONE_POLYGON:New("Ramat David Warehouse Spawn Zone #001", GROUP:FindByName("Ramat David Warehouse Spawn Zone #001")))
warehouse.Rayak:SetSpawnZone(ZONE_POLYGON:New("Rayak Warehouse Spawn Zone #001", GROUP:FindByName("Rayak Warehouse Spawn Zone #001")))
warehouse.ReneMouawad:SetSpawnZone(ZONE_POLYGON:New("Rene Mouawad Warehouse Spawn Zone #001", GROUP:FindByName("Rene Mouawad Warehouse Spawn Zone #001")))
warehouse.Tabqa:SetSpawnZone(ZONE_POLYGON:New("Tabqa Warehouse Spawn Zone #001", GROUP:FindByName("Tabqa Warehouse Spawn Zone #001")))
warehouse.Taftanaz:SetSpawnZone(ZONE_POLYGON:New("Taftanaz Warehouse Spawn Zone #001", GROUP:FindByName("Taftanaz Warehouse Spawn Zone #001")))
warehouse.WujahAlHajar:SetSpawnZone(ZONE_POLYGON:New("Wujah Al Hajar Warehouse Spawn Zone #001", GROUP:FindByName("Wujah Al Hajar Warehouse Spawn Zone #001")))

----Spawn Units after Capture
function warehouse.AbualDuhur:OnAfterCaptured(From, Event, To, Coalition, Country)
  if Coalition==coalition.side.BLUE then
    MESSAGE:New("We have captured Abu al-Duhur Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToBlue()
    warehouse.AbualDuhur:__Save(10,nil,"WarehouseAbualDuhur")
    warehouse.AbualDuhur:__AddRequest(900,warehouse.AbualDuhur,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT Merkava", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.AbualDuhur:__AddRequest(900,warehouse.AbualDuhur,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV M2A1", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.AbualDuhur:__AddRequest(900,warehouse.AbualDuhur,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Vulcan", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.AbualDuhur:__AddRequest(1800,warehouse.AbualDuhur,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Avenger", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.AbualDuhur:__AddRequest(1800,warehouse.AbualDuhur,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Hawk", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.AbualDuhur:__Save(1950,nil,"WarehouseAbualDuhur")    
  elseif Coalition==coalition.side.RED then
    MESSAGE:New("We have captured Abu al-Duhur Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToRed()
    warehouse.AbualDuhur:__Save(10,nil,"WarehouseAbualDuhur")
    warehouse.AbualDuhur:__AddRequest(900,warehouse.AbualDuhur,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT T72B", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.AbualDuhur:__AddRequest(900,warehouse.AbualDuhur,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV BMP-3", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.AbualDuhur:__AddRequest(900,warehouse.AbualDuhur,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Shilka", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.AbualDuhur:__AddRequest(1800,warehouse.AbualDuhur,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-13", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.AbualDuhur:__AddRequest(1800,warehouse.AbualDuhur,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-11", 1,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.AbualDuhur:__Save(1950,nil,"WarehouseAbualDuhur")    
    end
end
function warehouse.AdanaSakirpasa:OnAfterCaptured(From, Event, To, Coalition, Country)
  if Coalition==coalition.side.BLUE then
    MESSAGE:New("We have captured Abu al-Duhur Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToBlue()
    warehouse.AdanaSakirpasa:__Save(10,nil,"WarehouseAdanaSakirpasa")
    warehouse.AdanaSakirpasa:__AddRequest(900,warehouse.AdanaSakirpasa,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT Merkava", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.AdanaSakirpasa:__AddRequest(900,warehouse.AdanaSakirpasa,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV M2A1", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.AdanaSakirpasa:__AddRequest(900,warehouse.AdanaSakirpasa,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Vulcan", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.AdanaSakirpasa:__AddRequest(1800,warehouse.AdanaSakirpasa,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Avenger", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.AdanaSakirpasa:__AddRequest(1800,warehouse.AdanaSakirpasa,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Hawk", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.AdanaSakirpasa:__Save(1950,nil,"WarehouseAdanaSakirpasa")    
  elseif Coalition==coalition.side.RED then
    MESSAGE:New("We have captured Abu al-Duhur Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToRed()
    warehouse.AdanaSakirpasa:__Save(10,nil,"WarehouseAdanaSakirpasa")
    warehouse.AdanaSakirpasa:__AddRequest(900,warehouse.AdanaSakirpasa,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT T72B", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.AdanaSakirpasa:__AddRequest(900,warehouse.AdanaSakirpasa,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV BMP-3", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.AdanaSakirpasa:__AddRequest(900,warehouse.AdanaSakirpasa,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Shilka", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.AdanaSakirpasa:__AddRequest(1800,warehouse.AdanaSakirpasa,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-13", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.AdanaSakirpasa:__AddRequest(1800,warehouse.AdanaSakirpasa,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-11", 1,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.AdanaSakirpasa:__Save(1950,nil,"WarehouseAdanaSakirpasa")    
    end
end
function warehouse.AlDumayr:OnAfterCaptured(From, Event, To, Coalition, Country)
  if Coalition==coalition.side.BLUE then
    MESSAGE:New("We have captured Al Dumayr Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToBlue()
    warehouse.AlDumayr:__Save(10,nil,"WarehouseAlDumayr")
    warehouse.AlDumayr:__AddRequest(900,warehouse.AlDumayr,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT Merkava", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.AlDumayr:__AddRequest(900,warehouse.AlDumayr,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV M2A1", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.AlDumayr:__AddRequest(900,warehouse.AlDumayr,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Vulcan", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.AlDumayr:__AddRequest(1800,warehouse.AlDumayr,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Avenger", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.AlDumayr:__AddRequest(1800,warehouse.AlDumayr,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Hawk", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.AlDumayr:__Save(1950,nil,"WarehouseAlDumayr")    
  elseif Coalition==coalition.side.RED then
    MESSAGE:New("We have captured Al Dumayr Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToRed()
    warehouse.AlDumayr:__Save(10,nil,"WarehouseAlDumayr")
    warehouse.AlDumayr:__AddRequest(900,warehouse.AlDumayr,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT T72B", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.AlDumayr:__AddRequest(900,warehouse.AlDumayr,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV BMP-3", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.AlDumayr:__AddRequest(900,warehouse.AlDumayr,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Shilka", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.AlDumayr:__AddRequest(1800,warehouse.AlDumayr,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-13", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.AlDumayr:__AddRequest(1800,warehouse.AlDumayr,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-11", 1,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.AlDumayr:__Save(1950,nil,"WarehouseAlDumayr")    
    end
end
function warehouse.Aleppo:OnAfterCaptured(From, Event, To, Coalition, Country)
  if Coalition==coalition.side.BLUE then
    MESSAGE:New("We have captured Aleppo Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToBlue()
    warehouse.Aleppo:__Save(10,nil,"WarehouseAleppo")
    warehouse.Aleppo:__AddRequest(900,warehouse.Aleppo,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT Merkava", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Aleppo:__AddRequest(900,warehouse.Aleppo,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV M2A1", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Aleppo:__AddRequest(900,warehouse.Aleppo,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Vulcan", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Aleppo:__AddRequest(1800,warehouse.Aleppo,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Avenger", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Aleppo:__AddRequest(1800,warehouse.Aleppo,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Hawk", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Aleppo:__Save(1950,nil,"WarehouseAleppo")    
  elseif Coalition==coalition.side.RED then
    MESSAGE:New("We have captured Aleppo Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToRed()
    warehouse.Aleppo:__Save(10,nil,"WarehouseAleppo")
    warehouse.Aleppo:__AddRequest(900,warehouse.Aleppo,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT T72B", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Aleppo:__AddRequest(900,warehouse.Aleppo,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV BMP-3", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Aleppo:__AddRequest(900,warehouse.Aleppo,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Shilka", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Aleppo:__AddRequest(1800,warehouse.Aleppo,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-13", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Aleppo:__AddRequest(1800,warehouse.Aleppo,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-11", 1,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Aleppo:__Save(1950,nil,"WarehouseAleppo")    
    end
end
function warehouse.AlQusayr:OnAfterCaptured(From, Event, To, Coalition, Country)
  if Coalition==coalition.side.BLUE then
    MESSAGE:New("We have captured Al-Qusayr Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToBlue()
    warehouse.AlQusayr:__Save(10,nil,"WarehouseAlQusayr")
    warehouse.AlQusayr:__AddRequest(900,warehouse.AlQusayr,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT Merkava", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.AlQusayr:__AddRequest(900,warehouse.AlQusayr,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV M2A1", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.AlQusayr:__AddRequest(900,warehouse.AlQusayr,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Vulcan", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.AlQusayr:__AddRequest(1800,warehouse.AlQusayr,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Avenger", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.AlQusayr:__AddRequest(1800,warehouse.AlQusayr,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Hawk", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.AlQusayr:__Save(1950,nil,"WarehouseAleppo")    
  elseif Coalition==coalition.side.RED then
    MESSAGE:New("We have captured Al-Qusayr Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToRed()
    warehouse.AlQusayr:__Save(10,nil,"WarehouseAlQusayr")
    warehouse.AlQusayr:__AddRequest(900,warehouse.AlQusayr,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT T72B", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.AlQusayr:__AddRequest(900,warehouse.AlQusayr,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV BMP-3", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.AlQusayr:__AddRequest(900,warehouse.AlQusayr,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Shilka", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.AlQusayr:__AddRequest(1800,warehouse.AlQusayr,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-13", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.AlQusayr:__AddRequest(1800,warehouse.AlQusayr,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-11", 1,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.AlQusayr:__Save(1950,nil,"WarehouseAlQusayr")    
    end
end
function warehouse.AnNasiriyah:OnAfterCaptured(From, Event, To, Coalition, Country)
  if Coalition==coalition.side.BLUE then
    MESSAGE:New("We have captured An Nasiriyah Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToBlue()
    warehouse.AnNasiriyah:__Save(10,nil,"WarehouseAnNasiriyah")
    warehouse.AnNasiriyah:__AddRequest(900,warehouse.AnNasiriyah,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT Merkava", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.AnNasiriyah:__AddRequest(900,warehouse.AnNasiriyah,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV M2A1", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.AnNasiriyah:__AddRequest(900,warehouse.AnNasiriyah,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Vulcan", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.AnNasiriyah:__AddRequest(1800,warehouse.AnNasiriyah,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Avenger", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.AnNasiriyah:__AddRequest(1800,warehouse.AnNasiriyah,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Hawk", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.AnNasiriyah:__Save(1950,nil,"WarehouseAnNasiriyah")    
  elseif Coalition==coalition.side.RED then
    MESSAGE:New("We have captured An Nasiriyah Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToRed()
    warehouse.AnNasiriyah:__Save(10,nil,"WarehouseAnNasiriyah")
    warehouse.AnNasiriyah:__AddRequest(900,warehouse.AnNasiriyah,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT T72B", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.AnNasiriyah:__AddRequest(900,warehouse.AnNasiriyah,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV BMP-3", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.AnNasiriyah:__AddRequest(900,warehouse.AnNasiriyah,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Shilka", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.AnNasiriyah:__AddRequest(1800,warehouse.AnNasiriyah,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-13", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.AnNasiriyah:__AddRequest(1800,warehouse.AnNasiriyah,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-11", 1,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.AnNasiriyah:__Save(1950,nil,"WarehouseAnNasiriyah")    
    end
end
function warehouse.BasselAlAssad:OnAfterCaptured(From, Event, To, Coalition, Country)
  if Coalition==coalition.side.BLUE then
    MESSAGE:New("We have captured Bassel Al-Assad Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToBlue()
    warehouse.BasselAlAssad:__Save(10,nil,"WarehouseBasselAlAssad")
    warehouse.BasselAlAssad:__AddRequest(900,warehouse.BasselAlAssad,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT Merkava", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.BasselAlAssad:__AddRequest(900,warehouse.BasselAlAssad,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV M2A1", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.BasselAlAssad:__AddRequest(900,warehouse.BasselAlAssad,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Vulcan", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.BasselAlAssad:__AddRequest(1800,warehouse.BasselAlAssad,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Avenger", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.BasselAlAssad:__AddRequest(1800,warehouse.BasselAlAssad,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Hawk", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.BasselAlAssad:__Save(1950,nil,"WarehouseBasselAlAssad")    
  elseif Coalition==coalition.side.RED then
    MESSAGE:New("We have captured Bassel Al-Assad Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToRed()
    warehouse.BasselAlAssad:__Save(10,nil,"WarehouseBasselAlAssad")
    warehouse.BasselAlAssad:__AddRequest(900,warehouse.BasselAlAssad,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT T72B", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.BasselAlAssad:__AddRequest(900,warehouse.BasselAlAssad,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV BMP-3", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.BasselAlAssad:__AddRequest(900,warehouse.BasselAlAssad,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Shilka", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.BasselAlAssad:__AddRequest(1800,warehouse.BasselAlAssad,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-13", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.BasselAlAssad:__AddRequest(1800,warehouse.BasselAlAssad,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-11", 1,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.BasselAlAssad:__Save(1950,nil,"WarehouseBasselAlAssad")    
    end
end
function warehouse.BeirutRaficHariri:OnAfterCaptured(From, Event, To, Coalition, Country)
  if Coalition==coalition.side.BLUE then
    MESSAGE:New("We have captured Beirut-Rafic Hariri Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToBlue()
    warehouse.BeirutRaficHariri:__Save(10,nil,"WarehouseBeirutRaficHariri")
    warehouse.BeirutRaficHariri:__AddRequest(900,warehouse.BeirutRaficHariri,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT Merkava", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.BeirutRaficHariri:__AddRequest(900,warehouse.BeirutRaficHariri,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV M2A1", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.BeirutRaficHariri:__AddRequest(900,warehouse.BeirutRaficHariri,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Vulcan", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.BeirutRaficHariri:__AddRequest(1800,warehouse.BeirutRaficHariri,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Avenger", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.BeirutRaficHariri:__AddRequest(1800,warehouse.BeirutRaficHariri,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Hawk", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.BeirutRaficHariri:__Save(1950,nil,"WarehouseBeirutRaficHariri")    
  elseif Coalition==coalition.side.RED then
    MESSAGE:New("We have captured Beirut-Rafic Hariri Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToRed()
    warehouse.BeirutRaficHariri:__Save(10,nil,"WarehouseBeirutRaficHariri")
    warehouse.BeirutRaficHariri:__AddRequest(900,warehouse.BeirutRaficHariri,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT T72B", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.BeirutRaficHariri:__AddRequest(900,warehouse.BeirutRaficHariri,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV BMP-3", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.BeirutRaficHariri:__AddRequest(900,warehouse.BeirutRaficHariri,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Shilka", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.BeirutRaficHariri:__AddRequest(1800,warehouse.BeirutRaficHariri,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-13", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.BeirutRaficHariri:__AddRequest(1800,warehouse.BeirutRaficHariri,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-11", 1,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.BeirutRaficHariri:__Save(1950,nil,"WarehouseBeirutRaficHariri")    
    end
end
function warehouse.Damascus:OnAfterCaptured(From, Event, To, Coalition, Country)
  if Coalition==coalition.side.BLUE then
    MESSAGE:New("We have captured Damascus Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToBlue()
    warehouse.Damascus:__Save(10,nil,"WarehouseDamascus")
    warehouse.Damascus:__AddRequest(900,warehouse.Damascus,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT Merkava", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Damascus:__AddRequest(900,warehouse.Damascus,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV M2A1", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Damascus:__AddRequest(900,warehouse.Damascus,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Vulcan", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Damascus:__AddRequest(1800,warehouse.Damascus,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Avenger", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Damascus:__AddRequest(1800,warehouse.Damascus,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Hawk", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Damascus:__Save(1950,nil,"WarehouseDamascus")    
  elseif Coalition==coalition.side.RED then
    MESSAGE:New("We have captured Damascus Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToRed()
    warehouse.Damascus:__Save(10,nil,"WarehouseDamascus")
    warehouse.Damascus:__AddRequest(900,warehouse.Damascus,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT T72B", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Damascus:__AddRequest(900,warehouse.Damascus,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV BMP-3", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Damascus:__AddRequest(900,warehouse.Damascus,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Shilka", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Damascus:__AddRequest(1800,warehouse.Damascus,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-13", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Damascus:__AddRequest(1800,warehouse.Damascus,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-11", 1,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Damascus:__Save(1950,nil,"WarehouseDamascus")    
    end
end
function warehouse.EynShemer:OnAfterCaptured(From, Event, To, Coalition, Country)
  if Coalition==coalition.side.BLUE then
    MESSAGE:New("We have captured Eyn Shemer Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToBlue()
    warehouse.EynShemer:__Save(10,nil,"WarehouseEynShemer")
    warehouse.Hama:__AddRequest(900,warehouse.Hama,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT Merkava", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.EynShemer:__AddRequest(900,warehouse.EynShemer,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV M2A1", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.EynShemer:__AddRequest(900,warehouse.EynShemer,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Vulcan", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.EynShemer:__AddRequest(1800,warehouse.EynShemer,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Avenger", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.EynShemer:__AddRequest(1800,warehouse.EynShemer,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Hawk", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.EynShemer:__Save(1950,nil,"WarehouseEynShemer")    
  elseif Coalition==coalition.side.RED then
    MESSAGE:New("We have captured Eyn Shemer Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToRed()
    warehouse.EynShemer:__Save(10,nil,"WarehouseEynShemer")
    warehouse.EynShemer:__AddRequest(900,warehouse.EynShemer,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT T72B", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.EynShemer:__AddRequest(900,warehouse.EynShemer,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV BMP-3", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.EynShemer:__AddRequest(900,warehouse.EynShemer,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Shilka", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.EynShemer:__AddRequest(1800,warehouse.EynShemer,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-13", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.EynShemer:__AddRequest(1800,warehouse.EynShemer,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-11", 1,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.EynShemer:__Save(1950,nil,"WarehouseEynShemer")    
    end
end
function warehouse.Haifa:OnAfterCaptured(From, Event, To, Coalition, Country)
  if Coalition==coalition.side.BLUE then
    MESSAGE:New("We have captured Haifa Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToBlue()
    warehouse.Haifa:__Save(10,nil,"WarehouseHaifa")
    warehouse.Hama:__AddRequest(900,warehouse.Hama,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT Merkava", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Haifa:__AddRequest(900,warehouse.Haifa,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV M2A1", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Haifa:__AddRequest(900,warehouse.Haifa,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Vulcan", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Haifa:__AddRequest(1800,warehouse.Haifa,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Avenger", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Haifa:__AddRequest(1800,warehouse.Haifa,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Hawk", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Haifa:__Save(1950,nil,"WarehouseHaifa")    
  elseif Coalition==coalition.side.RED then
    MESSAGE:New("We have captured Haifa Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToRed()
    warehouse.Haifa:__Save(10,nil,"WarehouseHaifa")
    warehouse.Haifa:__AddRequest(900,warehouse.Haifa,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT T72B", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Haifa:__AddRequest(900,warehouse.Haifa,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV BMP-3", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Haifa:__AddRequest(900,warehouse.Haifa,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Shilka", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Haifa:__AddRequest(1800,warehouse.Haifa,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-13", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Haifa:__AddRequest(1800,warehouse.Haifa,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-11", 1,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Haifa:__Save(1950,nil,"WarehouseHaifa")    
    end
end
function warehouse.Hama:OnAfterCaptured(From, Event, To, Coalition, Country)
  if Coalition==coalition.side.BLUE then
    MESSAGE:New("We have captured Hama Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToBlue()
    warehouse.Hama:__Save(10,nil,"WarehouseHama")
    warehouse.Hama:__AddRequest(900,warehouse.Hama,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT Merkava", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Hama:__AddRequest(900,warehouse.Hama,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV M2A1", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Hama:__AddRequest(900,warehouse.Hama,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Vulcan", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Hama:__AddRequest(1800,warehouse.Hama,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Avenger", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Hama:__AddRequest(1800,warehouse.Hama,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Hawk", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Hama:__Save(1950,nil,"WarehouseHama")    
  elseif Coalition==coalition.side.RED then
    MESSAGE:New("We have captured Hama Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToRed()
    warehouse.Hama:__Save(10,nil,"WarehouseHama")
    warehouse.Hama:__AddRequest(900,warehouse.Hama,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT T72B", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Hama:__AddRequest(900,warehouse.Hama,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV BMP-3", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Hama:__AddRequest(900,warehouse.Hama,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Shilka", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Hama:__AddRequest(1800,warehouse.Hama,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-13", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Hama:__AddRequest(1800,warehouse.Hama,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-11", 1,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Hama:__Save(1950,nil,"WarehouseHama")    
    end
end
function warehouse.Hatay:OnAfterCaptured(From, Event, To, Coalition, Country)
  if Coalition==coalition.side.BLUE then
    MESSAGE:New("We have captured Hatay Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToBlue()
    warehouse.Hatay:__Save(10,nil,"WarehouseHatay")
    warehouse.Hatay:__AddRequest(900,warehouse.Hatay,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT Merkava", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Hatay:__AddRequest(900,warehouse.Hatay,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV M2A1", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Hatay:__AddRequest(900,warehouse.Hatay,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Vulcan", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Hatay:__AddRequest(1800,warehouse.Hatay,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Avenger", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Hatay:__AddRequest(1800,warehouse.Hatay,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Hawk", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Hatay:__Save(1950,nil,"WarehouseHatay")    
  elseif Coalition==coalition.side.RED then
    MESSAGE:New("We have captured Hatay Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToRed()
    warehouse.Hatay:__Save(10,nil,"WarehouseHatay")
    warehouse.Hatay:__AddRequest(900,warehouse.Hatay,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT T72B", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Hatay:__AddRequest(900,warehouse.Hatay,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV BMP-3", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Hatay:__AddRequest(900,warehouse.Hatay,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Shilka", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Hatay:__AddRequest(1800,warehouse.Hatay,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-13", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Hatay:__AddRequest(1800,warehouse.Hatay,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-11", 1,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Hatay:__Save(1950,nil,"WarehouseHatay")    
    end
end
function warehouse.Incirlik:OnAfterCaptured(From, Event, To, Coalition, Country)
  if Coalition==coalition.side.BLUE then
    MESSAGE:New("We have captured Incirlik Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToBlue()
    warehouse.Incirlik:__Save(10,nil,"WarehouseIncirlik")
    warehouse.Incirlik:__AddRequest(900,warehouse.Incirlik,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT Merkava", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Incirlik:__AddRequest(900,warehouse.Incirlik,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV M2A1", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Incirlik:__AddRequest(900,warehouse.Incirlik,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Vulcan", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Incirlik:__AddRequest(1800,warehouse.Incirlik,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Avenger", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Incirlik:__AddRequest(1800,warehouse.Incirlik,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Hawk", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Incirlik:__Save(1950,nil,"WarehouseIncirlik")    
  elseif Coalition==coalition.side.RED then
    MESSAGE:New("We have captured Incirlik Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToRed()
    warehouse.Incirlik:__Save(10,nil,"WarehouseIncirlik")
    warehouse.Incirlik:__AddRequest(900,warehouse.Incirlik,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT T72B", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Incirlik:__AddRequest(900,warehouse.Incirlik,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV BMP-3", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Incirlik:__AddRequest(900,warehouse.Incirlik,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Shilka", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Incirlik:__AddRequest(1800,warehouse.Incirlik,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-13", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Incirlik:__AddRequest(1800,warehouse.Incirlik,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-11", 1,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Incirlik:__Save(1950,nil,"WarehouseIncirlik")    
    end
end
function warehouse.Jirah:OnAfterCaptured(From, Event, To, Coalition, Country)
  if Coalition==coalition.side.BLUE then
    MESSAGE:New("We have captured Jirah Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToBlue()
    warehouse.Jirah:__Save(10,nil,"WarehouseJirah")
    warehouse.Jirah:__AddRequest(900,warehouse.Jirah,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT Merkava", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Jirah:__AddRequest(900,warehouse.Jirah,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV M2A1", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Jirah:__AddRequest(900,warehouse.Jirah,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Vulcan", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Jirah:__AddRequest(1800,warehouse.Jirah,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Avenger", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Jirah:__AddRequest(1800,warehouse.Jirah,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Hawk", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Jirah:__Save(1950,nil,"WarehouseJirah")    
  elseif Coalition==coalition.side.RED then
    MESSAGE:New("We have captured Jirah Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToRed()
    warehouse.Jirah:__Save(10,nil,"WarehouseJirah")
    warehouse.Jirah:__AddRequest(900,warehouse.Jirah,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT T72B", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Jirah:__AddRequest(900,warehouse.Jirah,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV BMP-3", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Jirah:__AddRequest(900,warehouse.Jirah,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Shilka", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Jirah:__AddRequest(1800,warehouse.Jirah,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-13", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Jirah:__AddRequest(1800,warehouse.Jirah,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-11", 1,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Jirah:__Save(1950,nil,"WarehouseJirah")    
    end
end
function warehouse.Khalkhalah:OnAfterCaptured(From, Event, To, Coalition, Country)
  if Coalition==coalition.side.BLUE then
    MESSAGE:New("We have captured Khalkhalah Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToBlue()
    warehouse.Khalkhalah:__Save(10,nil,"WarehouseKhalkhalah")
    warehouse.Khalkhalah:__AddRequest(900,warehouse.Khalkhalah,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT Merkava", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Khalkhalah:__AddRequest(900,warehouse.Khalkhalah,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV M2A1", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Khalkhalah:__AddRequest(900,warehouse.Khalkhalah,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Vulcan", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Khalkhalah:__AddRequest(1800,warehouse.Khalkhalah,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Avenger", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Khalkhalah:__AddRequest(1800,warehouse.Khalkhalah,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Hawk", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Khalkhalah:__Save(1950,nil,"WarehouseKhalkhalah")    
  elseif Coalition==coalition.side.RED then
    MESSAGE:New("We have captured Khalkhalah Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToRed()
    warehouse.Khalkhalah:__Save(10,nil,"WarehouseKhalkhalah")
    warehouse.Khalkhalah:__AddRequest(900,warehouse.Khalkhalah,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT T72B", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Khalkhalah:__AddRequest(900,warehouse.Khalkhalah,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV BMP-3", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Khalkhalah:__AddRequest(900,warehouse.Khalkhalah,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Shilka", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Khalkhalah:__AddRequest(1800,warehouse.Khalkhalah,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-13", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Khalkhalah:__AddRequest(1800,warehouse.Khalkhalah,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-11", 1,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Khalkhalah:__Save(1950,nil,"WarehouseKhalkhalah")    
    end
end
function warehouse.KingHusseinAirCollege:OnAfterCaptured(From, Event, To, Coalition, Country)
  if Coalition==coalition.side.BLUE then
    MESSAGE:New("We have captured King Hussein Air College Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToBlue()
    warehouse.KingHusseinAirCollege:__Save(10,nil,"WarehouseKingHusseinAirCollege")
    warehouse.KingHusseinAirCollege:__AddRequest(900,warehouse.KingHusseinAirCollege,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT Merkava", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.KingHusseinAirCollege:__AddRequest(900,warehouse.KingHusseinAirCollege,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV M2A1", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.KingHusseinAirCollege:__AddRequest(900,warehouse.KingHusseinAirCollege,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Vulcan", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.KingHusseinAirCollege:__AddRequest(1800,warehouse.KingHusseinAirCollege,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Avenger", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.KingHusseinAirCollege:__AddRequest(1800,warehouse.KingHusseinAirCollege,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Hawk", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.KingHusseinAirCollege:__Save(1950,nil,"WarehouseKingHusseinAirCollege")    
  elseif Coalition==coalition.side.RED then
    MESSAGE:New("We have captured King Hussein Air College Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToRed()
    warehouse.KingHusseinAirCollege:__Save(10,nil,"WarehouseKingHusseinAirCollege")
    warehouse.KingHusseinAirCollege:__AddRequest(900,warehouse.KingHusseinAirCollege,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT T72B", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.KingHusseinAirCollege:__AddRequest(900,warehouse.KingHusseinAirCollege,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV BMP-3", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.KingHusseinAirCollege:__AddRequest(900,warehouse.KingHusseinAirCollege,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Shilka", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.KingHusseinAirCollege:__AddRequest(1800,warehouse.KingHusseinAirCollege,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-13", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.KingHusseinAirCollege:__AddRequest(1800,warehouse.KingHusseinAirCollege,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-11", 1,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.KingHusseinAirCollege:__Save(1950,nil,"WarehouseKingHusseinAirCollege")    
    end
end
function warehouse.KiryatShmona:OnAfterCaptured(From, Event, To, Coalition, Country)
  if Coalition==coalition.side.BLUE then
    MESSAGE:New("We have captured Kiryat Shmona Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToBlue()
    warehouse.KiryatShmona:__Save(10,nil,"WarehouseKiryatShmona")
    warehouse.KiryatShmona:__AddRequest(900,warehouse.KiryatShmona,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT Merkava", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.KiryatShmona:__AddRequest(900,warehouse.KiryatShmona,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV M2A1", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.KiryatShmona:__AddRequest(900,warehouse.KiryatShmona,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Vulcan", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.KiryatShmona:__AddRequest(1800,warehouse.KiryatShmona,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Avenger", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.KiryatShmona:__AddRequest(1800,warehouse.KiryatShmona,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Hawk", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.KiryatShmona:__Save(1950,nil,"WarehouseKiryatShmona")    
  elseif Coalition==coalition.side.RED then
    MESSAGE:New("We have captured Kiryat Shmona Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToRed()
    warehouse.KiryatShmona:__Save(10,nil,"WarehouseKiryatShmona")
    warehouse.KiryatShmona:__AddRequest(900,warehouse.KiryatShmona,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT T72B", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.KiryatShmona:__AddRequest(900,warehouse.KiryatShmona,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV BMP-3", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.KiryatShmona:__AddRequest(900,warehouse.KiryatShmona,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Shilka", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.KiryatShmona:__AddRequest(1800,warehouse.KiryatShmona,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-13", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.KiryatShmona:__AddRequest(1800,warehouse.KiryatShmona,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-11", 1,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.KiryatShmona:__Save(1950,nil,"WarehouseKiryatShmona")    
    end
end
function warehouse.Kuweires:OnAfterCaptured(From, Event, To, Coalition, Country)
  if Coalition==coalition.side.BLUE then
    MESSAGE:New("We have captured Kuweires Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToBlue()
    warehouse.Kuweires:__Save(10,nil,"WarehouseKuweires")
    warehouse.Kuweires:__AddRequest(900,warehouse.Kuweires,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT Merkava", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Kuweires:__AddRequest(900,warehouse.Kuweires,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV M2A1", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Kuweires:__AddRequest(900,warehouse.Kuweires,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Vulcan", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Kuweires:__AddRequest(1800,warehouse.Kuweires,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Avenger", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Kuweires:__AddRequest(1800,warehouse.Kuweires,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Hawk", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Kuweires:__Save(1950,nil,"WarehouseKuweires")    
  elseif Coalition==coalition.side.RED then
    MESSAGE:New("We have captured Kuweires Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToRed()
    warehouse.Kuweires:__Save(10,nil,"WarehouseKuweires")
    warehouse.Kuweires:__AddRequest(900,warehouse.Kuweires,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT T72B", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Kuweires:__AddRequest(900,warehouse.Kuweires,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV BMP-3", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Kuweires:__AddRequest(900,warehouse.Kuweires,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Shilka", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Kuweires:__AddRequest(1800,warehouse.Kuweires,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-13", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Kuweires:__AddRequest(1800,warehouse.Kuweires,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-11", 1,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Kuweires:__Save(1950,nil,"WarehouseKuweires")    
    end
end
function warehouse.MarjasSultanNorth:OnAfterCaptured(From, Event, To, Coalition, Country)
  if Coalition==coalition.side.BLUE then
    MESSAGE:New("We have captured Marj as Sultan North Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToBlue()
    warehouse.MarjasSultanNorth:__Save(10,nil,"WarehouseMarjasSultanNorth")
    warehouse.MarjasSultanNorth:__AddRequest(900,warehouse.MarjasSultanNorth,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT Merkava", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.MarjasSultanNorth:__AddRequest(900,warehouse.MarjasSultanNorth,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV M2A1", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.MarjasSultanNorth:__AddRequest(900,warehouse.MarjasSultanNorth,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Vulcan", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.MarjasSultanNorth:__AddRequest(1800,warehouse.MarjasSultanNorth,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Avenger", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.MarjasSultanNorth:__AddRequest(1800,warehouse.MarjasSultanNorth,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Hawk", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.MarjasSultanNorth:__Save(1950,nil,"WarehouseMarjasSultanNorth")    
  elseif Coalition==coalition.side.RED then
    MESSAGE:New("We have captured Marj as Sultan North Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToRed()
    warehouse.MarjasSultanNorth:__Save(10,nil,"WarehouseMarjasSultanNorth")
    warehouse.MarjasSultanNorth:__AddRequest(900,warehouse.MarjasSultanNorth,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT T72B", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.MarjasSultanNorth:__AddRequest(900,warehouse.MarjasSultanNorth,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV BMP-3", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.MarjasSultanNorth:__AddRequest(900,warehouse.MarjasSultanNorth,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Shilka", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.MarjasSultanNorth:__AddRequest(1800,warehouse.MarjasSultanNorth,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-13", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.MarjasSultanNorth:__AddRequest(1800,warehouse.MarjasSultanNorth,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-11", 1,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.MarjasSultanNorth:__Save(1950,nil,"WarehouseMarjasSultanNorth")    
    end
end
function warehouse.MarjasSultanSouth:OnAfterCaptured(From, Event, To, Coalition, Country)
  if Coalition==coalition.side.BLUE then
    MESSAGE:New("We have captured Marj as Sultan South Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToBlue()
    warehouse.MarjasSultanSouth:__Save(10,nil,"WarehouseMarjasSultanSouth")
    warehouse.MarjasSultanSouth:__AddRequest(900,warehouse.MarjasSultanSouth,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT Merkava", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.MarjasSultanSouth:__AddRequest(900,warehouse.MarjasSultanSouth,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV M2A1", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.MarjasSultanSouth:__AddRequest(900,warehouse.MarjasSultanSouth,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Vulcan", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.MarjasSultanSouth:__AddRequest(1800,warehouse.MarjasSultanSouth,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Avenger", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.MarjasSultanSouth:__AddRequest(1800,warehouse.MarjasSultanSouth,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Hawk", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.MarjasSultanSouth:__Save(1950,nil,"WarehouseMarjasSultanSouth")    
  elseif Coalition==coalition.side.RED then
    MESSAGE:New("We have captured Marj as Sultan South Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToRed()
    warehouse.MarjasSultanSouth:__Save(10,nil,"WarehouseMarjasSultanSouth")
    warehouse.MarjasSultanSouth:__AddRequest(900,warehouse.MarjasSultanSouth,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT T72B", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.MarjasSultanSouth:__AddRequest(900,warehouse.MarjasSultanSouth,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV BMP-3", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.MarjasSultanSouth:__AddRequest(900,warehouse.MarjasSultanSouth,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Shilka", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.MarjasSultanSouth:__AddRequest(1800,warehouse.MarjasSultanSouth,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-13", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.MarjasSultanSouth:__AddRequest(1800,warehouse.MarjasSultanSouth,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-11", 1,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.MarjasSultanSouth:__Save(1950,nil,"WarehouseMarjasSultanSouth")    
    end
end
function warehouse.MarjRuhayyil:OnAfterCaptured(From, Event, To, Coalition, Country)
  if Coalition==coalition.side.BLUE then
    MESSAGE:New("We have captured Marj Ruhayyil Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToBlue()
    warehouse.MarjRuhayyil:__Save(10,nil,"WarehouseMarjRuhayyil")
    warehouse.MarjRuhayyil:__AddRequest(900,warehouse.MarjRuhayyil,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT Merkava", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.MarjRuhayyil:__AddRequest(900,warehouse.MarjRuhayyil,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV M2A1", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.MarjRuhayyil:__AddRequest(900,warehouse.MarjRuhayyil,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Vulcan", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.MarjRuhayyil:__AddRequest(1800,warehouse.MarjRuhayyil,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Avenger", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.MarjRuhayyil:__AddRequest(1800,warehouse.MarjRuhayyil,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Hawk", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.MarjRuhayyil:__Save(1950,nil,"WarehouseMarjRuhayyil")    
  elseif Coalition==coalition.side.RED then
    MESSAGE:New("We have captured Marj Ruhayyil Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToRed()
    warehouse.MarjRuhayyil:__Save(10,nil,"WarehouseMarjRuhayyil")
    warehouse.MarjRuhayyil:__AddRequest(900,warehouse.MarjRuhayyil,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT T72B", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.MarjRuhayyil:__AddRequest(900,warehouse.MarjRuhayyil,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV BMP-3", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.MarjRuhayyil:__AddRequest(900,warehouse.MarjRuhayyil,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Shilka", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.MarjRuhayyil:__AddRequest(1800,warehouse.MarjRuhayyil,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-13", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.MarjRuhayyil:__AddRequest(1800,warehouse.MarjRuhayyil,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-11", 1,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.MarjRuhayyil:__Save(1950,nil,"WarehouseMarjRuhayyil")    
    end
end
function warehouse.Megiddo:OnAfterCaptured(From, Event, To, Coalition, Country)
  if Coalition==coalition.side.BLUE then
    MESSAGE:New("We have captured Megiddo Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToBlue()
    warehouse.Megiddo:__Save(10,nil,"WarehouseMegiddo")
    warehouse.Megiddo:__AddRequest(900,warehouse.Megiddo,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT Merkava", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Megiddo:__AddRequest(900,warehouse.Megiddo,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV M2A1", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Megiddo:__AddRequest(900,warehouse.Megiddo,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Vulcan", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Megiddo:__AddRequest(1800,warehouse.Megiddo,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Avenger", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Megiddo:__AddRequest(1800,warehouse.Megiddo,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Hawk", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Megiddo:__Save(1950,nil,"WarehouseMegiddo")    
  elseif Coalition==coalition.side.RED then
    MESSAGE:New("We have captured Megiddo Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToRed()
    warehouse.Megiddo:__Save(10,nil,"WarehouseMegiddo")
    warehouse.Megiddo:__AddRequest(900,warehouse.Megiddo,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT T72B", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Megiddo:__AddRequest(900,warehouse.Megiddo,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV BMP-3", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Megiddo:__AddRequest(900,warehouse.Megiddo,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Shilka", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Megiddo:__AddRequest(1800,warehouse.Megiddo,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-13", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Megiddo:__AddRequest(1800,warehouse.Megiddo,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-11", 1,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Megiddo:__Save(1950,nil,"WarehouseMegiddo")    
    end
end
function warehouse.Mezzeh:OnAfterCaptured(From, Event, To, Coalition, Country)
  if Coalition==coalition.side.BLUE then
    MESSAGE:New("We have captured Mezzeh Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToBlue()
    warehouse.Mezzeh:__Save(10,nil,"WarehouseMezzeh")
    warehouse.Mezzeh:__AddRequest(900,warehouse.Mezzeh,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT Merkava", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Mezzeh:__AddRequest(900,warehouse.Mezzeh,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV M2A1", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Mezzeh:__AddRequest(900,warehouse.Mezzeh,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Vulcan", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Mezzeh:__AddRequest(1800,warehouse.Mezzeh,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Avenger", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Mezzeh:__AddRequest(1800,warehouse.Mezzeh,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Hawk", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Mezzeh:__Save(1950,nil,"WarehouseMezzeh")    
  elseif Coalition==coalition.side.RED then
    MESSAGE:New("We have captured Mezzeh Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToRed()
    warehouse.Mezzeh:__Save(10,nil,"WarehouseMezzeh")
    warehouse.Mezzeh:__AddRequest(900,warehouse.Mezzeh,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT T72B", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Mezzeh:__AddRequest(900,warehouse.Mezzeh,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV BMP-3", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Mezzeh:__AddRequest(900,warehouse.Mezzeh,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Shilka", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Mezzeh:__AddRequest(1800,warehouse.Mezzeh,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-13", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Mezzeh:__AddRequest(1800,warehouse.Mezzeh,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-11", 1,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Mezzeh:__Save(1950,nil,"WarehouseMezzeh")    
    end
end
function warehouse.Minakh:OnAfterCaptured(From, Event, To, Coalition, Country)
  if Coalition==coalition.side.BLUE then
    MESSAGE:New("We have captured Minakh Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToBlue()
    warehouse.Minakh:__Save(10,nil,"WarehouseMinakh")
    warehouse.Minakh:__AddRequest(900,warehouse.Minakh,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT Merkava", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Minakh:__AddRequest(900,warehouse.Minakh,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV M2A1", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Minakh:__AddRequest(900,warehouse.Minakh,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Vulcan", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Minakh:__AddRequest(1800,warehouse.Minakh,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Avenger", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Minakh:__AddRequest(1800,warehouse.Minakh,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Hawk", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Minakh:__Save(1950,nil,"WarehouseMinakh")    
  elseif Coalition==coalition.side.RED then
    MESSAGE:New("We have captured Minakh Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToRed()
    warehouse.Minakh:__Save(10,nil,"WarehouseMinakh")
    warehouse.Minakh:__AddRequest(900,warehouse.Minakh,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT T72B", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Minakh:__AddRequest(900,warehouse.Minakh,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV BMP-3", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Minakh:__AddRequest(900,warehouse.Minakh,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Shilka", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Minakh:__AddRequest(1800,warehouse.Minakh,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-13", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Minakh:__AddRequest(1800,warehouse.Minakh,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-11", 1,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Minakh:__Save(1950,nil,"WarehouseMinakh")    
    end
end
function warehouse.Palmyra:OnAfterCaptured(From, Event, To, Coalition, Country)
  if Coalition==coalition.side.BLUE then
    MESSAGE:New("We have captured Minakh Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToBlue()
    warehouse.Palmyra:__Save(10,nil,"WarehousePalmyra")
    warehouse.Palmyra:__AddRequest(900,warehouse.Palmyra,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT Merkava", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Palmyra:__AddRequest(900,warehouse.Palmyra,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV M2A1", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Palmyra:__AddRequest(900,warehouse.Palmyra,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Vulcan", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Palmyra:__AddRequest(1800,warehouse.Palmyra,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Avenger", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Palmyra:__AddRequest(1800,warehouse.Palmyra,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Hawk", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Palmyra:__Save(1950,nil,"WarehousePalmyra")    
  elseif Coalition==coalition.side.RED then
    MESSAGE:New("We have captured Palmyra Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToRed()
    warehouse.Palmyra:__Save(10,nil,"WarehousePalmyra")
    warehouse.Palmyra:__AddRequest(900,warehouse.Palmyra,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT T72B", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Palmyra:__AddRequest(900,warehouse.Palmyra,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV BMP-3", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Palmyra:__AddRequest(900,warehouse.Palmyra,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Shilka", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Palmyra:__AddRequest(1800,warehouse.Palmyra,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-13", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Palmyra:__AddRequest(1800,warehouse.Palmyra,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-11", 1,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Palmyra:__Save(1950,nil,"WarehousePalmyra")    
    end
end
function warehouse.QabrasSitt:OnAfterCaptured(From, Event, To, Coalition, Country)
  if Coalition==coalition.side.BLUE then
    MESSAGE:New("We have captured Qabr as Sitt Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToBlue()
    warehouse.QabrasSitt:__Save(10,nil,"WarehouseQabrasSitt")
    warehouse.QabrasSitt:__AddRequest(900,warehouse.QabrasSitt,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT Merkava", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.QabrasSitt:__AddRequest(900,warehouse.QabrasSitt,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV M2A1", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.QabrasSitt:__AddRequest(900,warehouse.QabrasSitt,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Vulcan", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.QabrasSitt:__AddRequest(1800,warehouse.QabrasSitt,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Avenger", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.QabrasSitt:__AddRequest(1800,warehouse.QabrasSitt,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Hawk", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.QabrasSitt:__Save(1950,nil,"WarehouseQabrasSitt")    
  elseif Coalition==coalition.side.RED then
    MESSAGE:New("We have captured Qabr as Sitt Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToRed()
    warehouse.QabrasSitt:__Save(10,nil,"WarehouseQabrasSitt")
    warehouse.QabrasSitt:__AddRequest(900,warehouse.QabrasSitt,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT T72B", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.QabrasSitt:__AddRequest(900,warehouse.QabrasSitt,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV BMP-3", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.QabrasSitt:__AddRequest(900,warehouse.QabrasSitt,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Shilka", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.QabrasSitt:__AddRequest(1800,warehouse.QabrasSitt,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-13", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.QabrasSitt:__AddRequest(1800,warehouse.QabrasSitt,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-11", 1,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.QabrasSitt:__Save(1950,nil,"WarehouseQabrasSitt")    
    end
end
function warehouse.RamatDavid:OnAfterCaptured(From, Event, To, Coalition, Country)
  if Coalition==coalition.side.BLUE then
    MESSAGE:New("We have captured Ramat David Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToBlue()
    warehouse.RamatDavid:__Save(10,nil,"WarehouseRamatDavid")
    warehouse.RamatDavid:__AddRequest(900,warehouse.RamatDavid,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT Merkava", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.RamatDavid:__AddRequest(900,warehouse.RamatDavid,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV M2A1", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.RamatDavid:__AddRequest(900,warehouse.RamatDavid,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Vulcan", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.RamatDavid:__AddRequest(1800,warehouse.RamatDavid,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Avenger", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.RamatDavid:__AddRequest(1800,warehouse.RamatDavid,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Hawk", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.RamatDavid:__Save(1950,nil,"WarehouseRamatDavid")    
  elseif Coalition==coalition.side.RED then
    MESSAGE:New("We have captured Ramat David Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToRed()
    warehouse.RamatDavid:__Save(10,nil,"WarehouseRamatDavid")
    warehouse.RamatDavid:__AddRequest(900,warehouse.RamatDavid,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT T72B", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.RamatDavid:__AddRequest(900,warehouse.RamatDavid,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV BMP-3", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.RamatDavid:__AddRequest(900,warehouse.RamatDavid,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Shilka", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.RamatDavid:__AddRequest(1800,warehouse.RamatDavid,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-13", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.RamatDavid:__AddRequest(1800,warehouse.RamatDavid,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-11", 1,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.RamatDavid:__Save(1950,nil,"WarehouseRamatDavid")    
    end
end
function warehouse.Rayak:OnAfterCaptured(From, Event, To, Coalition, Country)
  if Coalition==coalition.side.BLUE then
    MESSAGE:New("We have captured Rayak Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToBlue()
    warehouse.Rayak:__Save(10,nil,"WarehouseRayak")
    warehouse.Rayak:__AddRequest(900,warehouse.Rayak,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT Merkava", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Rayak:__AddRequest(900,warehouse.Rayak,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV M2A1", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Rayak:__AddRequest(900,warehouse.Rayak,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Vulcan", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Rayak:__AddRequest(1800,warehouse.Rayak,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Avenger", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Rayak:__AddRequest(1800,warehouse.Rayak,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Hawk", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Rayak:__Save(1950,nil,"WarehouseRayak")    
  elseif Coalition==coalition.side.RED then
    MESSAGE:New("We have captured Rayak Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToRed()
    warehouse.Rayak:__Save(10,nil,"WarehouseRayak")
    warehouse.Rayak:__AddRequest(900,warehouse.Rayak,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT T72B", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Rayak:__AddRequest(900,warehouse.Rayak,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV BMP-3", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Rayak:__AddRequest(900,warehouse.Rayak,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Shilka", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Rayak:__AddRequest(1800,warehouse.Rayak,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-13", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Rayak:__AddRequest(1800,warehouse.Rayak,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-11", 1,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Rayak:__Save(1950,nil,"WarehouseRayak")    
    end
end
function warehouse.ReneMouawad:OnAfterCaptured(From, Event, To, Coalition, Country)
  if Coalition==coalition.side.BLUE then
    MESSAGE:New("We have captured Rene Mouawad Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToBlue()
    warehouse.ReneMouawad:__Save(10,nil,"WarehouseReneMouawad")
    warehouse.ReneMouawad:__AddRequest(900,warehouse.ReneMouawad,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT Merkava", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.ReneMouawad:__AddRequest(900,warehouse.ReneMouawad,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV M2A1", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.ReneMouawad:__AddRequest(900,warehouse.ReneMouawad,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Vulcan", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.ReneMouawad:__AddRequest(1800,warehouse.ReneMouawad,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Avenger", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.ReneMouawad:__AddRequest(1800,warehouse.ReneMouawad,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Hawk", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.ReneMouawad:__Save(1950,nil,"WarehouseReneMouawad")    
  elseif Coalition==coalition.side.RED then
    MESSAGE:New("We have captured Rene Mouawad Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToRed()
    warehouse.ReneMouawad:__Save(10,nil,"WarehouseReneMouawad")
    warehouse.ReneMouawad:__AddRequest(900,warehouse.ReneMouawad,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT T72B", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.ReneMouawad:__AddRequest(900,warehouse.ReneMouawad,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV BMP-3", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.ReneMouawad:__AddRequest(900,warehouse.ReneMouawad,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Shilka", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.ReneMouawad:__AddRequest(1800,warehouse.ReneMouawad,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-13", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.ReneMouawad:__AddRequest(1800,warehouse.ReneMouawad,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-11", 1,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.ReneMouawad:__Save(1950,nil,"WarehouseReneMouawad")    
    end
end
function warehouse.Tabqa:OnAfterCaptured(From, Event, To, Coalition, Country)
  if Coalition==coalition.side.BLUE then
    MESSAGE:New("We have captured Tabqa Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToBlue()
    warehouse.Tabqa:__Save(10,nil,"WarehouseTabqa")
    warehouse.Tabqa:__AddRequest(900,warehouse.Tabqa,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT Merkava", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Tabqa:__AddRequest(900,warehouse.Tabqa,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV M2A1", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Tabqa:__AddRequest(900,warehouse.Tabqa,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Vulcan", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Tabqa:__AddRequest(1800,warehouse.Tabqa,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Avenger", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Tabqa:__AddRequest(1800,warehouse.Tabqa,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Hawk", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Tabqa:__Save(1950,nil,"WarehouseTabqa")    
  elseif Coalition==coalition.side.RED then
    MESSAGE:New("We have captured Tabqa Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToRed()
    warehouse.Tabqa:__Save(10,nil,"WarehouseTabqa")
    warehouse.Tabqa:__AddRequest(900,warehouse.Tabqa,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT T72B", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Tabqa:__AddRequest(900,warehouse.Tabqa,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV BMP-3", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Tabqa:__AddRequest(900,warehouse.Tabqa,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Shilka", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Tabqa:__AddRequest(1800,warehouse.Tabqa,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-13", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Tabqa:__AddRequest(1800,warehouse.Tabqa,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-11", 1,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Tabqa:__Save(1950,nil,"WarehouseTabqa")    
    end
end
function warehouse.Taftanaz:OnAfterCaptured(From, Event, To, Coalition, Country)
  if Coalition==coalition.side.BLUE then
    MESSAGE:New("We have captured Taftanaz Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToBlue()
    warehouse.Taftanaz:__Save(10,nil,"WarehouseTaftanaz")
    warehouse.Taftanaz:__AddRequest(900,warehouse.Taftanaz,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT Merkava", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Taftanaz:__AddRequest(900,warehouse.Taftanaz,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV M2A1", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Taftanaz:__AddRequest(900,warehouse.Taftanaz,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Vulcan", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Taftanaz:__AddRequest(1800,warehouse.Taftanaz,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Avenger", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Taftanaz:__AddRequest(1800,warehouse.Taftanaz,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Hawk", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Taftanaz:__Save(1950,nil,"WarehouseTaftanaz")    
  elseif Coalition==coalition.side.RED then
    MESSAGE:New("We have captured Taftanaz Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToRed()
    warehouse.Taftanaz:__Save(10,nil,"WarehouseTaftanaz")
    warehouse.Taftanaz:__AddRequest(900,warehouse.Taftanaz,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT T72B", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Taftanaz:__AddRequest(900,warehouse.Taftanaz,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV BMP-3", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Taftanaz:__AddRequest(900,warehouse.Taftanaz,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Shilka", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Taftanaz:__AddRequest(1800,warehouse.Taftanaz,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-13", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Taftanaz:__AddRequest(1800,warehouse.Taftanaz,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-11", 1,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.Taftanaz:__Save(1950,nil,"WarehouseTaftanaz")    
    end
end
function warehouse.WujahAlHajar:OnAfterCaptured(From, Event, To, Coalition, Country)
  if Coalition==coalition.side.BLUE then
    MESSAGE:New("We have captured Wujah Al Hajar Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToBlue()
    warehouse.WujahAlHajar:__Save(10,nil,"WarehouseWujahAlHajar")
    warehouse.WujahAlHajar:__AddRequest(900,warehouse.WujahAlHajar,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT Merkava", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.WujahAlHajar:__AddRequest(900,warehouse.WujahAlHajar,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV M2A1", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.WujahAlHajar:__AddRequest(900,warehouse.WujahAlHajar,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Vulcan", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.WujahAlHajar:__AddRequest(1800,warehouse.WujahAlHajar,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Avenger", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.WujahAlHajar:__AddRequest(1800,warehouse.WujahAlHajar,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM Hawk", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.WujahAlHajar:__Save(1950,nil,"WarehouseWujahAlHajar")    
  elseif Coalition==coalition.side.RED then
    MESSAGE:New("We have captured Wujah Al Hajar Warehouse, Quick Reaction Force enroute ETA 15 min, follow forces in 30 minutes.",25,"Allies:"):ToRed()
    warehouse.WujahAlHajar:__Save(10,nil,"WarehouseWujahAlHajar")
    warehouse.WujahAlHajar:__AddRequest(900,warehouse.WujahAlHajar,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply MBT T72B", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.WujahAlHajar:__AddRequest(900,warehouse.WujahAlHajar,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply IFV BMP-3", 2,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.WujahAlHajar:__AddRequest(900,warehouse.WujahAlHajar,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply AAA Shilka", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.WujahAlHajar:__AddRequest(1800,warehouse.WujahAlHajar,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-13", 4,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.WujahAlHajar:__AddRequest(1800,warehouse.WujahAlHajar,
    WAREHOUSE.Descriptor.GROUPNAME, "Resupply SAM SA-11", 1,
    WAREHOUSE.TransportType.SELFPROPELLED)
    warehouse.WujahAlHajar:__Save(1950,nil,"WarehouseWujahAlHajar")    
    end
end

----Save Warehouses outside of the capture
--WAREHOUSE.Save(self,path,filename)
--warehouse.Minakh:Save(path,filename)
--warehouse.Minakh:__Save(delay,path,filename)

warehouse.AbualDuhur:__Save(3600,nil,"WarehouseAbualDuhur")
warehouse.AdanaSakirpasa:__Save(3600,nil,"WarehouseAdanaSakirpasa")
warehouse.AlDumayr:__Save(3610,nil,"WarehouseAlDumayr")
warehouse.Aleppo:__Save(3620,nil,"WarehouseAleppo")
warehouse.AlQusayr:__Save(3630,nil,"WarehouseAlQusayr")
warehouse.AlQusayr:__Save(3640,nil,"WarehouseAlQusayr")
warehouse.AnNasiriyah:__Save(3650,nil,"WarehouseAnNasiriyah")
warehouse.BasselAlAssad:__Save(3660,nil,"WarehouseBasselAlAssad")
warehouse.BeirutRaficHariri:__Save(3670,nil,"WarehouseBeirutRaficHariri")
warehouse.Damascus:__Save(3675,nil,"WarehouseDamascus")
warehouse.EynShemer:__Save(3680,nil,"WarehouseEynShemer")
warehouse.Haifa:__Save(3680,nil,"WarehouseHaifa")
warehouse.Hama:__Save(3680,nil,"WarehouseHama")
warehouse.Hatay:__Save(3690,nil,"WarehouseHatay")
warehouse.Incirlik:__Save(3700,nil,"WarehouseIncirlik")
warehouse.Jirah:__Save(3710,nil,"WarehouseJirah")
warehouse.Khalkhalah:__Save(3720,nil,"WarehouseKhalkhalah")
warehouse.KingHusseinAirCollege:__Save(3730,nil,"WarehouseKingHusseinAirCollege")
warehouse.KiryatShmona:__Save(3740,nil,"WarehouseKiryatShmona")
warehouse.Kuweires:__Save(3750,nil,"WarehouseKuweires")
warehouse.MarjasSultanNorth:__Save(3760,nil,"WarehouseMarjasSultanNorth")
warehouse.MarjasSultanSouth:__Save(3770,nil,"WarehouseMarjasSultanSouth")
warehouse.MarjRuhayyil:__Save(3780,nil,"WarehouseMarjRuhayyil")
warehouse.Megiddo:__Save(3790,nil,"WarehouseMegiddo")
warehouse.Mezzeh:__Save(3795,nil,"WarehouseMezzeh")
warehouse.Minakh:__Save(3800,nil,"WarehouseMinakh")
warehouse.Palmyra:__Save(3800,nil,"WarehousePalmyra")
warehouse.QabrasSitt:__Save(3810,nil,"WarehouseQabrasSitt")
warehouse.RamatDavid:__Save(3820,nil,"WarehouseRamatDavid")
warehouse.Rayak:__Save(3830,nil,"WarehouseRayak")
warehouse.ReneMouawad:__Save(3840,nil,"WarehouseReneMouawad")
warehouse.Tabqa:__Save(3850,nil,"WarehouseTabqa")
warehouse.Taftanaz:__Save(3850,nil,"WarehouseTaftanaz")
warehouse.WujahAlHajar:__Save(3860,nil,"WarehouseWujahAlHajar")