<div align="center">
<table width="94%" border="0" cellspacing=3 cellpadding=0>

dnl ========== BANNER ========================================================

  <tr><td valign=middle>
  <span class=banner>imglink([TYPHON], [typhon.png], [http://typhon.sf.net])</span></td></tr>

  <tr><td>include_image([-], [line.blue.gif], [height="4" width="100%" style="margin-bottom:5px"])
  </td></tr>

dnl ========== main frame - 2 columns ========================================

  <tr><td width="100%">

  <table width="100%" bgcolor="d7e6ef" background="img_dir([vbar-bluegrad.png])" 
    border=0 cellspacing="0" cellpadding="0">
    <tr valign="top">
dnl ========== menu ==========================================================
    <td>
    include([menu.m4])
    write_menu_left
    </td>
    <td style="background-color: FFFFFF; width: 5px">&nbsp;</td> 
dnl ========== contents frame ================================================
    <td bgcolor=FFFFFF width="100%" class="defaut">
      write_menu_head  <br>
      <p class=titre> page_title </p>
      <div class=body>
