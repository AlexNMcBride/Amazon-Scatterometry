load('/auto/home/mcbride/Amazon-Scatterometry/data/amazon_mask.mat');
load("/auto/home/mcbride/Amazon-Scatterometry/data/ascat_scat_acc.mat")
climate=load("/auto/home/mcbride/Amazon-Scatterometry/data/climate_zones.mat").clip;
d=T(end,:).def2{1};
def_output = '/auto/home/mcbride/Amazon-Scatterometry/data/def_zones.mat';
pro_output = '/auto/home/mcbride/Amazon-Scatterometry/data/pro_zones.mat';
def_mask=double(mask);
pro_mask=double(mask);
% Zone 2 - Alta Floresta, Mato Grosso
dbox2y=435:490;
dbox2x=315:370;
% Zone 3 - Rio Brance, Acre
dbox3y=382:415;
dbox3x=175:197;
% Zone 4 - Roraima
dbox4y=180:215;
dbox4x=285:315;
% Zone 5 - Altamira, Para
dbox5y=260:285;
dbox5x=405:430;
% Zone 6 - Ipixuna, Amazonas
dbox6y=335:380;
dbox6x=95:155;
def_mask(dbox2y,dbox2x)=2;
def_mask(dbox3y,dbox3x)=3;
def_mask(dbox4y,dbox4x)=4;
def_mask(dbox5y,dbox5x)=5;
def_mask(dbox6y,dbox6x)=6;
% Zone 2 - Terra Indigena Menkragnoti
pbox2y=430:465;
pbox2x=396:411;
% Zone 3 - Floresta Nacional Mapia-Inauini, Terra Indigena Camicua
pbox3y=350:375;
pbox3x=160:190;
% Zone 4 - Reserva Biologica do Rio Trombetas/Uatuma
pbox4y=195:230;
pbox4x=325:350;
% Zone 5 - Estacao Ecologica da Terra do Meio, Terra Indigena Arawete
% Igarape Ipixuna
pbox5y=295:318;
pbox5x=390:415;
% Zone 6 - Terra Indigena Vale do Javari, Amazonas
pbox6y=300:325;
pbox6x=100:145;
pro_mask(pbox2y,pbox2x)=2;
pro_mask(pbox3y,pbox3x)=3;
pro_mask(pbox4y,pbox4x)=4;
pro_mask(pbox5y,pbox5x)=5;
pro_mask(pbox6y,pbox6x)=6;
pro_mask(~mask)=0;
def_mask(~mask)=0;
figure(1)
imagesc(d+def_mask*10+pro_mask*10+climate*10)

save(def_output, "def_mask");
save(pro_output, "pro_mask");
