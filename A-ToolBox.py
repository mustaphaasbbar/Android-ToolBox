#!/usr/bin/env python
# -*- coding: UTF-8 -*-
# Android Toolbox para Linux por xTirDev (cccb010) #

import pygtk
pygtk.require('2.0')
import gtk
import gtk.glade
import re
import os
from subprocess import call as ca
from subprocess import Popen as xproc

def hxa(cmd):
	pipa = xproc(r'{ ' + cmd + ';} 2>&1', shell=True, stdout=-1).pid
	return pipa
def h(cmd):
	pipa = xproc(r'{ ' + cmd + ';} 2>&1', shell=True, stdout=-1).stdout
	salida = pipa.read()
	if salida[-1:] == '\n': salida = salida[:-1]
	return salida

ath = h("./.rutaxd.sh")

borraryextraer=True
# Cambia el valor de "borraryextraer" a False si queres que este programa se abra un poco mas rapido
# Cambialo a True si queres que el programa pese menos

adbno = "./c/adb"
fastbootno = "./c/fastboot"
pred = ["system.img","data.img","recovery.img","boot.img"]
flash = ["system","userdata","recovery","boot"]
predb = [True,True,True,False]
def prope(linea):
	lope = ca(linea, shell=True)
	return lope

def getfbdev():
	fbdeva = h(fastbootno+" devices")
	if re.search("\?{12}\tfastboot", fbdeva) != None:
		return True
	elif re.search("\tfastboot", fbdeva) !=None:
		return True
	else:
		return False

class atrbx:
	def etcheck(self):
		etio = h("pidof easytether")
		if etio != "":
			h("sudo kill "+str(etio))
	def storage(self, widget):
		tc = self.usbstorage.get_active()
		self.etcheck()
		print(tc)
		if tc == True:
			r = h(adbno+" shell 'echo /dev/block/mmcblk0 > /sys/devices/platform/usb_mass_storage/lun0/file'")
			print(r)
		elif tc==False:
			r = h(adbno+" shell 'echo "" > /sys/devices/platform/usb_mass_storage/lun0/file'")
			print(r)
	def resdesdefb(self, widget):
		if getfbdev() == True:
			h(fastbootno+r" reboot")
		else:
			self.peb("No estas en modo fastboot")
			
	def resfastboot(self, widget):
		h(adbno+r" reboot bootloader")
	def resrecovery(self, widget):
		h(adbno+r" reboot recovery")
	def rescomun(self, widget):
		h(adbno+r" reboot")
	def chpred(self, widget):
		preda = 0
		if self.chsdbc[0].get_active()==True and self.chsdbc[1].get_active()==True and self.chsdbc[2].get_active()==True and self.chsdbc[3].get_active()==True:
			ke = False
		else:
			ke = True
		for k in self.chsdbc:
			self.chsdbc[preda].set_active(ke)
			preda+=1
			
	def predet(self, widget):
		preda = 0
		for k in self.esdbc:
			self.esdbc[preda].set_text(pred[preda])
			self.chsdbc[preda].set_active(predb[preda])
			preda+=1
			
	def coneteth(self, widget):
		self.peb("Cerrando adb...")
		h(adbno+" kill-server")
		self.peb("Conectando al dispositivo...")
		etpid = h("pidof easytether")
		h("kill "+str(etpid))
		hxa("easytether connect")
		self.peb("Resolviendo DNS...")
		si=h("dhclient easytether0")
		if re.search("No such device", si) != None:
			self.peb("Fallo al conectar, no hay dispositivo o no tiene conexion")
		else:
			self.peb("Conexion con easytether completa")
		
	def insetether(self, widget):
		self.peb("Copiando archivos al sistema...")
		h(r"tar xf ./.easytether.tz")
		err = h("cp -f -R -T './easytether/easytether' '/' ")
		self.peb("Archivos Copiados, instalando easytether en android")
		h(adbno+r" install "+"./easytether/easytether.apk")
		h("rm -R ./easytether")
		self.peb("Instalacion de EasyTether completa.")
		
	def dataresetf(self, widget):
		self.peb(" Revisando si hay dispositivo...")
		if getfbdev() == True:
			self.peb('Dispositivo encontrado, por favor espere...')	
			if self.chd2s.get_active()==True:
				te = h(fastbootno+" erase system")
			else:
				te = h(fastbootno+" erase userdata")
			self.peb(te)	
			te = h(fastbootno+" erase cache")
			self.peb(te)
			if re.search("erasing 'cache'\.{3} OKAY", te) !=None:
				self.peb("Reseteo de particion data completo")
		else:
			self.peb("No hay ningun dispositivo conectado")
			
	def cargando(self):
		wu = gtk.Window(gtk.WINDOW_POPUP)
		wu.set_position(gtk.WIN_POS_CENTER)
		caja = gtk.VBox(False, 0)
		imagen = gtk.Image()
		imagen.set_from_file(os.path.join(ath, '.pixmaps/Cargando.png'))
		caja.pack_start(imagen)
		wu.add(caja)
		wu.show_all()
		while gtk.events_pending():
			gtk.main_iteration()
		self.bdc.show_all()
		wu.destroy()
		
	def flasho(self, widget):
		nufla=0
		for t in flash:
			if self.chsdbc[nufla].get_active()==True:
				l = self.esdbc[nufla].get_text()
				if getfbdev() == True:
					self.peb("Flasheando " +l+ "...")
					h(fastbootno+r" flash "+flash[nufla]+r" ./rom/"+l)
					self.peb("Flasheando " +l+ "...")
				else:
					self.peb("No hay ningun dispositivo conectado")
			nufla+=1
		self.peb("Flasheo terminado")
		
	def bflashotrawin(self, widget):
		self.emr.show_all()
	def bfowde(self, widget):
		self.emr.hide_all()
		return True
	def flashearotracosa(self, widget):
		part = self.eparticionemr.get_text()
		img = self.earchivoemr.get_text()
		if getfbdev() == True:
			h(fastbootno+" flash "+str(part)+" ./rom/"+str(img))
		else:
			self.peb("No hay ningun dispositivo conectado")
			
	def data2sysrename(self, widget):
		if self.chd2s.get_active() == True:
			self.chsdbc[0].set_label("data")
			self.chsdbc[1].set_label("system")
			flash[0]="userdata"
			flash[1]="system"
		else:
			self.chsdbc[0].set_label("system")
			self.chsdbc[1].set_label("data")
			flash[0]="system"
			flash[1]="userdata"
			self.bdc.show_all()
			
	def instalarapp(self, widget):
		nombreapp=self.selapp.get_filenames()
		er = h(adbno+" install -r '"+str(nombreapp[0])+"'")
		if re.search("INSTALL_FAILED_INVALID_APK", er) != None:
			print "Fallo al instalar la apk"
			self.peb("Fallo al instalar la apk")
		else:
			self.peb("Instalacion de apk completa")
			print "Instalacion completa"
			
	def creardriveradb(self, widget):
		nombres = ("51-android.rules", "99-android.rules")
		h("cp ./c/adb /usr/bin")
		h("cp ./c/fastboot /usr/bin")
		marcas = ("","1004", "22B8", "0BB4","19D2", "0502", "0FCE", "04E8", "12D1", "0000")
		selmarca = self.widgets.get_widget("selmarca")
		nromarca = selmarca.get_active_text()
		nromarca = int(nromarca[0])
		adentro = ('SUBSYSTEM=="usb", SYSFS{idVendor}=="'+marcas[nromarca]+'", MODE="0666"','SUBSYSTEM=="usb", SYSFS{idVendor}=="18d1", MODE="0666"')
		ruta = '/etc/udev/rules.d/'
		for fh in nombres:
			fc = open(ruta+fh, 'w')
			fc.write(adentro[0]+"\n"+adentro[1])
			fc.close()
			h("chmod a+rx "+ruta+fh)
		h("restart udev")
		
	def root(self, widget):
		h(adbno+r" push ./root/rageagainstthecage-arm5.bin /data/local/tmp/rageagainstthecage")
		h(adbno+r" shell chmod 4755 /data/local/tmp/rageagaintthecage")
		h(adbno+r" shell /data/local/tmp/rageagainstthecage")
		h(adbno+r" wait-for-device")
		h(adbno+r" shell mount -o remount,rw -t yaffs2 /dev/block/mtdblock4 /system")
		h(adbno+r" push ./root/Superuser.apk /system/app")
		h(adbno+r" shell chmod 755 /system/app/Superuser.apk")
		h(adbno+r" push ./root/su /system/xbin/su")
		h(adbno+r" shell chmod 4755 /system/xbin/su")
		h(adbno+r" push ./root/su /system/bin/su")
		h(adbno+r" shell chmod 4755 /system/bin/su")
		h(adbno+r" shell rm /data/local/tmp/rageagainstthecage")
		h(adbno+r" shell reboot")
		
	def unroot(self, widget):
		h(adbno+r" wait-for-device")
		h(adbno+r" shell mount -o remount,rw -t yaffs2 /dev/block/mtdblock4 /system")
		h(adbno+r" shell rm /system/app/Superuser.apk")
		h(adbno+r" shell rm /system/xbin/su")
		h(adbno+r" shell rm /system/bin/su")
		h(adbno+r" shell reboot")
		
	def cot(self, widget):
		etpid = h("pidof easytether")
		h("kill "+str(etpid))
		h(adbno+" shell ls /system/xbin/su")
		ro = h(adbno+" shell ls /system/xbin/su")
		eas = h(adbno+" shell ls /data/app")
		if re.search("com.mstream.easytether_polyclef-1.apk", eas) != None:
			easytether="Instalado"
		else:
			easytether="No instalado"
		if ro== "/system/xbin/su\r":
			root="Activo"
		elif ro=="ls: /system/xbin/su: No such file or directory\r":
			root="Inactivo"
		else:
			root="(Desconocido)"
		self.rlabe.set_text(root)
		aa = h(adbno+' devices')
		fb = h(fastbootno+' devices')
		self.vf = 0
		dispos = "--------------adb--------------\n"+aa+"-----------fastboot----------\n"+fb
		self.lbf.set_text(dispos)
		self.eathl.set_text(easytether)
		self.peb("Progreso completado")
		
	def peb(self, texto):
		kg = self.ebar.get_context_id("Progreso")
		self.ebar.push(kg,texto)
		print(texto)
		while gtk.events_pending():
			gtk.main_iteration()
		
	def delete_event(self, widget, event):
		if borraryextraer==True:
			h("rm -R ./c")
			h("rm -R ./root")
		gtk.main_quit()
		
	def __init__(self):

		self.widgets = gtk.glade.XML("./.AndroidToolBox.glade")
		self.emr = self.widgets.get_widget("emr")
		self.bflashemr = self.widgets.get_widget("bflashemr")
		self.earchivoemr = self.widgets.get_widget("earchivoemr")
		self.eparticionemr = self.widgets.get_widget("eparticionemr")
		self.emr.connect("delete_event", self.bfowde)
		self.bflashemr.connect("clicked", self.flashearotracosa)
		self.emr.set_position(gtk.WIN_POS_CENTER)
		self.emr.set_title('Flashear otra particion')
		self.bdc = self.widgets.get_widget("atrollbox")
		self.bdc.set_position(gtk.WIN_POS_CENTER)
		self.ah = self.widgets.get_widget("table1")
		self.barraatb = gtk.Image()
		self.barraatb.set_from_file(os.path.join(ath, '.pixmaps/AndroidTBLogo.png'))
		self.ah.attach(self.barraatb,0,1,0,1)
		self.cargando(),
		if borraryextraer==True:
			h(r"tar xf ./.c.tz") , h(r"tar xf ./.root.tz")
		elif borraryextraer==False:
			lis = h("ls ./c/.adb")
			if re.search("ls: ", lis) != None:
				h(r"tar xf ./.c.tz"), h(r"tar xf ./.root.tz")		
		self.dis = self.widgets.get_widget("Devices")
		self.esdbc = range(4)
		self.chsdbc = range(4)
		for k in self.esdbc and self.chsdbc:
			self.esdbc[k] = 0
			self.chsdbc[k] = 0
		h(adbno+' devices')
		h(fastbootno+' devices')
		self.bpred = self.widgets.get_widget("bpred")
		self.bpred.connect("clicked", self.predet)
		self.esdbc[0] = self.widgets.get_widget("esy")
		self.chsdbc[0] = self.widgets.get_widget("chsy")
		self.chsdbc[1] = self.widgets.get_widget("chda")
		self.chsdbc[2] = self.widgets.get_widget("chca")
		self.chsdbc[3] = self.widgets.get_widget("chbo")
		self.esdbc[1] = self.widgets.get_widget("eda")
		self.esdbc[2] = self.widgets.get_widget("eca")
		self.esdbc[3] = self.widgets.get_widget("ebo")
		self.btodo = self.widgets.get_widget("btodo")
		self.btodo.connect("clicked", self.chpred)
		self.installb = self.widgets.get_widget("installb")
		self.chd2s = self.widgets.get_widget("chd2s")
		self.chd2s.connect("clicked", self.data2sysrename)
		self.installb.connect("clicked", self.instalarapp)
		self.brefresh = self.widgets.get_widget("refreshb")
		self.rlabe = self.widgets.get_widget("rlabe")
		self.bdc.connect("delete_event", self.delete_event)
		self.brefresh.connect("clicked", self.cot)
		self.ieth = self.widgets.get_widget("inseasytether")
		self.bflash = self.widgets.get_widget("bflash")
		self.eathl = self.widgets.get_widget("eathl")
		self.selapp = self.widgets.get_widget("selapp")
		self.bflash.connect("clicked", self.flasho)
		self.datareset = self.widgets.get_widget("datareset")
		self.datareset.connect("clicked", self.dataresetf)
		self.ieth.connect("clicked", self.insetether)
		self.etcon = self.widgets.get_widget("etcon")
		self.ebar = self.widgets.get_widget("estadobar")
		self.etcon.connect("clicked", self.coneteth)
		self.napp = self.widgets.get_widget("napp")
		self.rootb = self.widgets.get_widget("rootb")
		self.rootb.connect("clicked", self.root)
		self.urootb = self.widgets.get_widget("urootb")
		self.urootb.connect("clicked", self.unroot)
		self.brestar = self.widgets.get_widget("brestar")
		self.brestar.connect("clicked", self.rescomun)
		self.usbstorage = self.widgets.get_widget("usbstorage")
		self.usbstorage.connect("clicked", self.storage)
		self.brestarfastboot = self.widgets.get_widget("brestarfastboot")
		self.brestarfastboot.connect("clicked", self.resfastboot)
		self.brestarrecovery = self.widgets.get_widget("brestarrecovery")
		self.brestarrecovery.connect("clicked", self.resrecovery)
		self.binstaadbfb = self.widgets.get_widget("binstaadbfb")
		self.binstaadbfb.connect("clicked", self.creardriveradb)
		self.brestardesdefb = self.widgets.get_widget("brestardesdefb")
		self.brestardesdefb.connect("clicked", self.resdesdefb)
		self.bflashotra = self.widgets.get_widget("bflashotra")
		self.bflashotra.connect("clicked", self.bflashotrawin)
		self.bdc.set_title('Android ToolBox')
		self.lbf = self.dis.get_buffer()
		self.dis.set_buffer = self.lbf
		self.vf = 0
def main():
	gtk.main()
if __name__ == "__main__":
	eqtf = atrbx()
	main()
