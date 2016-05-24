
#COM/BİL 2000 (Microprocessors/Mikroişlemciler) Ödevi


##Mikroişlemciler dersi sayfasındaki [2. uygulama yönergesinde][11],Assembly dilinde kod geliştirmeyi sağlayan iki geçişli derleme ve tümleşik geliştirme ortamları ile 64-bit MicroSoft işletim sistemlerinde çalışabilen 32-bit Turbo Assembler ve Microsoft Assembler kullanılarak Assembly dilinde kod geliştirme örnekleri verilmiştir.
##Geliştireceğiniz program, komut satırından parametre olarak verilen giriş ve çıkış dosya adlarını kullanarak, unicode (UTF-16) biçimli giriş dosyasından okuduğu tüm karakterlerin Berger kodunu hesapladıktan sonra karakter’in 16 bit için kullanılmayan (null olan) kısmına ekleyerek çıkış dosyasına yazdırmalıdır.
##Programlarınızı kendi öğrenci numaranız ile adlandırarak geliştirmeniz gerekmektedir. Örneğin, numarası 123456 olan bir öğrencinin geliştireceği programın kaynak kodu 123456_kodla.asm ve çalıştırılabilir kodu 123456_kodla.exe adını taşımalı ve komut satırından; 123456_kodla.exe unicode_metin.txt berger_kodlu_metin.txt olarak çalıştırıldığında, unicode_metin.txt dosyasındaki tüm karakterlerin Berger kodu eklenmiş biçimini berger_kodlu_metin.txt çıkış dosyasına yazmalıdır.
##Berger kodlanmış metnin, flash saklama cihazlarında saklanması sırasında oluşabilecek tek yönlü bit hatalarını bulmak için kullanılacak Berger kodu denetleyen 123456_kodcoz.exe adlı çalıştırılabilir kodu, komut satırından; 123456_kodcoz.exe berger_kodlu_metin.txt unicode_metin.txt olarak çalıştırıldığında, berger_kodlu_metin.txt dosyasındaki tüm karakterlerin Berger kodu denetlenerek karakter tek yönlü bit hatası içermiyorsa unicode biçimindeki sonucunu unicode_metin.txt çıkış dosyasına yazmalıdır.  Berger kodu ile tek yönlü bit hatası belirlenen hatalı karakter(ler)in yerine çıkış dosyasına # karakteri yazılmalıdır.

##Uygun isimli programınızı değerlendirilmek üzere, derlenmesi için gereken tüm program adlarını içeren bir yığın betik (bat uzantılı batch dosya) ile, [http://bit.ly/mikro_odevyukle][12] adresini kullanarak 8 Mayıs 2016 tarihine kadar yüklemeniz gerekmektedir.

##Programınızı geliştirme sırasında kaynak olarak kullanabileceğiniz, komut satırından verilen iki dosya adını alarak giriş dosyasından okuduğu metini çıkış dosyasına  yazan bir Assembly dili programın Turbo ve Microsoft Assembler  için kaynak kodları, [http://ceng2.ktu.edu.tr/~ulutas/Courses/MicroProcessors/arg_masm.asm][13] ve [http://ceng2.ktu.edu.tr/~ulutas/Courses/MicroProcessors/arg_tasm.asm][14] dosyaları içinde bulunmaktadır.

##Sonuç: Berger kodlanmış assembly programına [buradan][16] ulaşabilirsiniz. 
      [Doç. Dr. Mustafa ULUTAŞ][15]
      28.04.2016


[11]:https://github.com/abdullahvelioglu/microprocessors/blob/master/instruction.md
[12]:http://bit.ly/mikro_odevyukle
[13]:http://ceng2.ktu.edu.tr/~ulutas/Courses/MicroProcessors/arg_masm.asm
[14]:http://ceng2.ktu.edu.tr/~ulutas/Courses/MicroProcessors/arg_tasm.asm
[15]:http://ceng2.ktu.edu.tr/~ulutas/Courses/MicroProcessors/
[16]:https://github.com/abdullahvelioglu/microprocessors/blob/master/bergercode.asm
