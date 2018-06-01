    BOOL APIENTRY DlgProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam)  
{               
	switch (msg) {      
		case WM_INITDIALOG:  
			static int a;   
	 		return TRUE;  
                   
	case WM_CLOSE:   
		int b;    
		EndDialog(hwnd, IDOK);    
		break;   
              
       case WM_COMMAND: 
           switch (LOWORD(wParam)) {  
               case IDC_EXIT:      
                    EndDialog(hwnd, IDOK); 
                    break;        
               case IDCANCEL:    
                    EndDialog(hwnd, IDCANCEL);   
			break;                    
           }       
           break;  
   }    
    return FALSE; 
}  