X2go - ��� ����� �������� ������ rdp, vnc � ���� �������� �����. � ������� ����������� ������� �� ������� ��������� ����� ������� �������� � ������������� ����������� ���������.
��������� x2go ������� �� Linux.
�� ������ ��� ���������� �� VPS Linux.

��������� x2go Debian\Ubuntu. ��� �������� �� ����� ��������� �� ���� Ubuntu 14.04 minimal.
1. ������� �� ������ �� SSH � ��������� �������������� �������.

apt-get update;apt-get install software-properties-common nano aptitude
2. ������� ����������� x2go.

add-apt-repository ppa:x2go/stable
� ���� �� ���������� ���������� ������������ ������� ������.
3. ��������� x2goserver.

apt-get update;apt-get install x2goserver x2goserver-xsession
4. ��������� ����������� ��������� XFCE.
������ ��� Ubuntu 12.04.

apt-get install xubuntu-desktop
����������� ��������� ����� ���� �����.
5. ������������ ������ (�� ������ ������).

reboot
��� ����������� � ��� ������ ������, � ������� ������ ���� ����.
6. ��������� �������� �����.
����������� ��� �������� ��������, ������� �� ������� �� ���������.

apt-get install language-pack-ru
����������� ��� ����������� ��������� Gnome.
]
apt-get install language-pack-gnome-ru
��������� �����������. ��� ����������� ���������� ��������� ��� ������� � ��������� � �������.

update-locale LANG=ru_RU.UTF-8