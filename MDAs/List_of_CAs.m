function zero = List_of_CAs(y_vect, x_vect)
% Call tools and compare their outputs to previous values
[mt L V mf] = tool1(y_vect,x_vect);
zero(1) = mt -y_vect(1);
[mt L V mf] = tool2(y_vect,x_vect);
zero(2) = L -y_vect(2);
[mt L V mf] = tool3(y_vect,x_vect);
zero(3) = V -y_vect(3);
[mt L V mf] = tool4(y_vect,x_vect);
zero(4) = mf -y_vect(4);

