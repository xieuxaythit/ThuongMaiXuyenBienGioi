// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

contract HopDongThuongMai {

    struct HopDong {
        address payable TaiKhoanNguoiMua;
        address payable TaiKhoanNguoiBan;
        address payable TaiKhoanVanChuyen;

        uint    TienHang;        // Tinh bang gwei (mot phan ty cua ETH)
        uint    TienVanChuyen;   // Tinh bang gwei (mot phan ty cua ETH)
        uint256 ToaDoGiaoHang;   // Ma bam cua toa do GPS
        uint    ThoiHanHopDong;

        enTrangThaiHopDong TrangThaiHopDong;
    }

    uint SoHopDong;
    mapping (uint => HopDong) DanhSachHopDong;    

    enum enTrangThaiHopDong {
        Moi,
        NguoiMuaDaDatCoc,
        HangDangGiao,
        HangDaToiDichRoi,
        ChoPhanXu,
        ThanhCong,
        ThatBai
    }

    event NguoiMuaDaDatCocRoi(uint256 intToaDoGiaoHang);
    event HangDangTrenDuongRoi();
    event HopDongThanhCongRoi();
    event HopDongDangChoPhanXu();

    // constructor (address payable adNguoiMua, address payable adNguoiBan, uint intTienHang, uint intTienVanChuyen) {
    //     TaiKhoanNguoiBan    = adNguoiBan;
    //     TaiKhoanNguoiMua    = adNguoiMua;
    //     TienHang            = intTienHang;      // tinh bang gwei
    //     TienVanChuyen       = intTienVanChuyen; // tinh bang gwei
    //     //ToaDoGiaoHang       = intToaDoGiaoHang;
    //     ThoiHanHopDong      = block.timestamp + 30 days;
        
    //     TrangThaiHopDong    = enTrangThaiHopDong.Moi;
    // }

    function TaoHopDongMoi(address payable adNguoiMua, address payable adNguoiBan, uint intTienHang, uint intTienVanChuyen) public returns (uint intMaSoHopDong) {
        //Tao ma so hop dong
        intMaSoHopDong = SoHopDong++;

        // Khoi tao hop dong moi trong danh sach voi ma so vua tao
        DanhSachHopDong[intMaSoHopDong] = HopDong({
                                                    TaiKhoanNguoiMua:   adNguoiMua, 
                                                    TaiKhoanNguoiBan:   adNguoiBan, 
                                                    TaiKhoanVanChuyen:  payable(address(0)),
                                                    TienHang:           intTienHang, 
                                                    TienVanChuyen:      intTienVanChuyen, 
                                                    ToaDoGiaoHang:      0, 
                                                    ThoiHanHopDong:     block.timestamp + 30 days,
                                                    TrangThaiHopDong:   enTrangThaiHopDong.Moi
                                                });

        // HopDong storage stHopDong   = DanhSachHopDong[MaSoHopDong];
        // stHopDong.TaiKhoanNguoiMua  = adNguoiMua;
        // stHopDong.TaiKhoanNguoiBan  = adNguoiBan;
        // stHopDong.TienHang          = intTienHang;
        // stHopDong.TienVanChuyen     = intTienVanChuyen;

        return intMaSoHopDong;
    }

    function DatCocMuaHang(uint intMaSoHopDong, uint256 intToaDoGiaoHang) payable public {
        
        // Lay hop dong tu danh sach theo intMaSoHopDong
        HopDong storage stHopDong = DanhSachHopDong[intMaSoHopDong];

        // Kiem tra dieu kien trang thai hop dong va so tien
        require(stHopDong.TrangThaiHopDong == enTrangThaiHopDong.Moi);
        require(msg.value >= ((stHopDong.TienHang + stHopDong.TienVanChuyen) * (1 gwei)));

        // Cap nhat trang thai va du lieu hop dong
        stHopDong.TrangThaiHopDong = enTrangThaiHopDong.NguoiMuaDaDatCoc;
        stHopDong.ToaDoGiaoHang = intToaDoGiaoHang;

        // Thong bao cho nguoi ban hang
        emit NguoiMuaDaDatCocRoi(intToaDoGiaoHang);
    }

    function DatCocVanChuyen(uint intMaSoHopDong) payable public {

        // Lay hop dong tu danh sach theo intMaSoHopDong
        HopDong storage stHopDong = DanhSachHopDong[intMaSoHopDong];

        // Kiem tra xem hop dong da dat coc chua
        require(stHopDong.TrangThaiHopDong == enTrangThaiHopDong.NguoiMuaDaDatCoc);

        // Kiem tra tien coc van chuyen tuong duong tien hang
        require(msg.value == stHopDong.TienHang * (1 gwei) );
        
        // Cap nhat trang thai hop dong
        stHopDong.TrangThaiHopDong = enTrangThaiHopDong.HangDangGiao;

        // Cap nhat nguoi van chuyen tien
        stHopDong.TaiKhoanVanChuyen = payable(msg.sender);

        // Thong bao cho cac ben la hang dang tren duong roi
        emit HangDangTrenDuongRoi();
    }

    function HangDaToiDich(uint intMaSoHopDong, uint256 intToaDoGiaoToi) public {

        // Lay hop dong tu danh sach theo intMaSoHopDong
        HopDong storage stHopDong = DanhSachHopDong[intMaSoHopDong];

        // Kiem tra xem co dung nguoi van chuyen khong, CHI CHO PHEP NGUOI VAN CHUYEN GOI HAM NAY
        require (msg.sender == stHopDong.TaiKhoanVanChuyen);

        // Kiem tra thoi gian giao hang trong han hop dong
        require (block.timestamp <= stHopDong.ThoiHanHopDong);

        //Kiem tra trang thai hop dong
        require(stHopDong.TrangThaiHopDong == enTrangThaiHopDong.HangDangGiao);

        // So khop toa do giao hang
        require(intToaDoGiaoToi == stHopDong.ToaDoGiaoHang);

        // Cap nhat trang thai hop dong khi giao hang dung toa do
        stHopDong.TrangThaiHopDong = enTrangThaiHopDong.HangDaToiDichRoi;
    }

    function NguoiMuaXacNhanHang(uint intMaSoHopDong, bool bHangOK) payable public {

        // Lay hop dong tu danh sach theo intMaSoHopDong
        HopDong storage stHopDong = DanhSachHopDong[intMaSoHopDong];

        // Kiem tra xem co dung nguoi mua khong, CHI CHO PHEP NGUOI MUA GOI HAM NAY
        require (msg.sender == stHopDong.TaiKhoanNguoiMua);

        // Thanh ly hop dong neu hang OK, neu hang khong OK thi cho xac nhan tiep theo cua nguoi van chuyen
        if(bHangOK == false) {
            // Cap nhat trang thai hop dong dang bi tranh chap, cho phan xu.
            stHopDong.TrangThaiHopDong = enTrangThaiHopDong.ChoPhanXu;

            // Thong bao cho cac ben ve trang thai hop dong dang cho phan xu
            emit HopDongDangChoPhanXu();
        }
        else {
            // Cap nhat trang thai hop duong
            stHopDong.TrangThaiHopDong = enTrangThaiHopDong.ThanhCong;

            // Tra tien cho nguoi ban
            stHopDong.TaiKhoanNguoiBan.transfer( stHopDong.TienHang * (1 gwei) );

            // Tra tien cho nguoi van chuyen (coc van chuyen + phi van chuyen)
            stHopDong.TaiKhoanVanChuyen.transfer( (stHopDong.TienHang + stHopDong.TienVanChuyen) * (1 gwei) );

            // Vet het tien con lai trong CONTRACT tra lai cho nguoi mua
            stHopDong.TaiKhoanNguoiMua.transfer( address(this).balance );

            // Thong bao cho cac ben la hop dong da thanh cong.
            emit HopDongThanhCongRoi();
        }
    }

    function NguoiVanChuyenXacNhanHang(uint intMaSoHopDong, bool bHangOK) payable public {
        
        // Lay hop dong tu danh sach theo intMaSoHopDong
        HopDong storage stHopDong = DanhSachHopDong[intMaSoHopDong];

        // Kiem tra xem co dung nguoi van chuyen khong, CHI CHO PHEP NGUOI VAN CHUYEN GOI HAM NAY
        require (msg.sender == stHopDong.TaiKhoanVanChuyen);

        require (stHopDong.TrangThaiHopDong == enTrangThaiHopDong.ChoPhanXu);

        if(bHangOK == false) {
            // Nguoi van chuyen cong nhan voi Nguoi mua hang bi hong 
            // Van tra tien cho nguoi ban binh thuong
            stHopDong.TaiKhoanNguoiBan.transfer( stHopDong.TienHang * (1 gwei) );

            // Tra lai toan bo tien con lai trong CONTRACT cho nguoi mua 
            stHopDong.TaiKhoanNguoiMua.transfer( address(this).balance );
        }
        else {
            // Nguoi van chuyen khong cong nhan hang hong, cho rang HangOK = TRUE
            // can xu ly them truong hop nay.

        }
    }

    function ThanhLyHopDong(uint intMaSoHopDong) payable public {
        
        // Lay hop dong tu danh sach theo intMaSoHopDong
        HopDong storage stHopDong = DanhSachHopDong[intMaSoHopDong];

        // Kiem tra truong hop qua han moi duoc thanh ly
        require (block.timestamp > stHopDong.ThoiHanHopDong);

        // Chi cho cac ben tham gia thanh ly hop dong
        require( msg.sender == stHopDong.TaiKhoanNguoiMua || msg.sender == stHopDong.TaiKhoanNguoiBan || msg.sender == stHopDong.TaiKhoanVanChuyen );

        // Thanh ly hop dong chi moi dat coc ma chua lam gi
        if (stHopDong.TrangThaiHopDong == enTrangThaiHopDong.NguoiMuaDaDatCoc) {
            // Tra lai tien cho nguoi mua toan bo so tien trong CONTRACT 
            stHopDong.TaiKhoanNguoiMua.transfer( address(this).balance );
        } 

        // Thanh ly hop dong dang giao hang thi chim tau 
        if (stHopDong.TrangThaiHopDong == enTrangThaiHopDong.HangDangGiao) {
            // Tra lai tien cho nguoi mua va nguoi ban
            stHopDong.TaiKhoanNguoiBan.transfer( stHopDong.TienHang * (1 gwei) );
            stHopDong.TaiKhoanNguoiMua.transfer( address(this).balance );
        }

        // Thanh ly hop dong khi den noi thi nguoi mua "CHET" hoac khong nhan hang
        if (stHopDong.TrangThaiHopDong == enTrangThaiHopDong.HangDaToiDichRoi) {
            // Chia ra 2 truong hop, thanh ly ngay, hoac la mang hang ve tra lai NGUOI BAN
            // TRUONG HOP THANH LY NGAY vi den day nguoi ban va nguoi van chuyen da hoan thanh trach nhiem
            // Tra tien cho nguoi ban binh thuong
            stHopDong.TaiKhoanNguoiBan.transfer( stHopDong.TienHang * (1 gwei) );

            // Tra tien cho nguoi van chuyen binh thuong 
            stHopDong.TaiKhoanVanChuyen.transfer( (stHopDong.TienHang + stHopDong.TienVanChuyen) * (1 gwei) );

            // Vet not tien con du trong CONTRACT tra lai cho nguoi mua 
            stHopDong.TaiKhoanNguoiMua.transfer( address(this).balance );
        }

        // Thanh ly hop dong dang cho phan xu
        if (stHopDong.TrangThaiHopDong == enTrangThaiHopDong.ChoPhanXu) {
            // Tra lai tien cho nguoi mua va nguoi ban
            stHopDong.TaiKhoanNguoiBan.transfer( stHopDong.TienHang * (1 gwei) );
            stHopDong.TaiKhoanNguoiMua.transfer( address(this).balance );
        }

    }
}