// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

contract HopDongThuongMai {
    address payable public TaiKhoanNguoiMua;
    address payable public TaiKhoanNguoiBan;
    address payable public TaiKhoanVanChuyen;

    uint    public TienHang;        // Tinh bang gwei (mot phan ty cua ETH)
    uint    public TienVanChuyen;   // Tinh bang gwei (mot phan ty cua ETH)
    uint256 public ToaDoGiaoHang;   // Ma bam cua toa do GPS
    uint    public ThoiHanHopDong;

    enum enTrangThaiHopDong {
        Moi,
        NguoiMuaDaDatCoc,
        HangDangGiao,
        HangDaToiDichRoi,
        ChoPhanXu,
        ThanhCong,
        ThatBai
    }

    enTrangThaiHopDong public TrangThaiHopDong;

    event NguoiMuaDaDatCocRoi(uint256 intToaDoGiaoHang);
    event HangDangTrenDuongRoi();
    event HopDongThanhCongRoi();

    constructor (address payable adNguoiMua, address payable adNguoiBan, uint intTienHang, uint intTienVanChuyen) {
        TaiKhoanNguoiBan    = adNguoiBan;
        TaiKhoanNguoiMua    = adNguoiMua;
        TienHang            = intTienHang;      // tinh bang gwei
        TienVanChuyen       = intTienVanChuyen; // tinh bang gwei
        //ToaDoGiaoHang       = intToaDoGiaoHang;
        ThoiHanHopDong      = block.timestamp + 30 days;
        
        TrangThaiHopDong    = enTrangThaiHopDong.Moi;
    }

    function DatCocMuaHang(uint256 intToaDoGiaoHang) payable public {
        
        // Kiem tra dieu kien trang thai hop dong va so tien
        require(TrangThaiHopDong == enTrangThaiHopDong.Moi);
        require(msg.value >= ((TienHang + TienVanChuyen) * (1 gwei)));

        // Cap nhat trang thai va du lieu hop dong
        TrangThaiHopDong = enTrangThaiHopDong.NguoiMuaDaDatCoc;
        ToaDoGiaoHang = intToaDoGiaoHang;

        // Thong bao cho nguoi bang
        emit NguoiMuaDaDatCocRoi(intToaDoGiaoHang);
    }

    function DatCocVanChuyen() payable public {

        // Kiem tra xem hop dong da dat coc chua
        require(TrangThaiHopDong == enTrangThaiHopDong.NguoiMuaDaDatCoc);

        // Kiem tra tien coc van chuyen tuong duong tien hang
        require(msg.value == TienHang * (1 gwei) );
        
        // Cap nhat trang thai hop dong
        TrangThaiHopDong = enTrangThaiHopDong.HangDangGiao;

        // Cap nhat nguoi van chuyen tien
        TaiKhoanVanChuyen = payable(msg.sender);

        // Thong bao cho cac ben la hang dang tren duong roi
        emit HangDangTrenDuongRoi();
    }

    function HangDaToiDich(uint256 intToaDoGiaoToi) public {

        // Kiem tra xem co dung nguoi van chuyen khong, CHI CHO PHEP NGUOI VAN CHUYEN GOI HAM NAY
        require (msg.sender == TaiKhoanVanChuyen);

        // Kiem tra thoi gian giao hang trong han hop dong
        require (block.timestamp <= ThoiHanHopDong);

        //Kiem tra trang thai hop dong
        require(TrangThaiHopDong == enTrangThaiHopDong.HangDangGiao);

        // So khop toa do giao hang
        require(intToaDoGiaoToi == ToaDoGiaoHang);

        // Cap nhat trang thai hop dong khi giao hang dung toa do
        TrangThaiHopDong = enTrangThaiHopDong.HangDaToiDichRoi;
    }

    function NguoiMuaXacNhanHang(bool bHangOK) payable public {

        // Kiem tra xem co dung nguoi mua khong, CHI CHO PHEP NGUOI MUA GOI HAM NAY
        require (msg.sender == TaiKhoanNguoiMua);

        // Thanh ly hop dong neu hang OK, neu hang khong OK thi cho xac nhan tiep theo cua nguoi van chuyen
        if(bHangOK == false) {
            TrangThaiHopDong = enTrangThaiHopDong.ChoPhanXu;
        }
        else {
            // Cap nhat trang thai hop duong
            TrangThaiHopDong = enTrangThaiHopDong.ThanhCong;

            // Tra tien cho nguoi ban
            TaiKhoanNguoiBan.transfer( TienHang * (1 gwei) );

            // Tra tien cho nguoi van chuyen (coc van chuyen + phi van chuyen)
            TaiKhoanVanChuyen.transfer( (TienHang + TienVanChuyen) * (1 gwei) );

            // Vet het tien con lai trong CONTRACT tra lai cho nguoi mua
            TaiKhoanNguoiMua.transfer( address(this).balance );

            emit HopDongThanhCongRoi();
        }
    }

    function NguoiVanChuyenXacNhanHang(bool bHangOK) payable public {
        
        // Kiem tra xem co dung nguoi van chuyen khong, CHI CHO PHEP NGUOI VAN CHUYEN GOI HAM NAY
        require (msg.sender == TaiKhoanVanChuyen);

        require (TrangThaiHopDong == enTrangThaiHopDong.ChoPhanXu);

        if(bHangOK == false) {
            // Nguoi van chuyen cong nhanh voi Nguoi mua hang bi hong 
            // Van tra tien cho nguoi ban binh thuong
            TaiKhoanNguoiBan.transfer( TienHang * (1 gwei) );

            // Tra lai toan bo tien con lai trong CONTRACT cho nguoi mua 
            TaiKhoanNguoiMua.transfer( address(this).balance );
        }
        else {
            // Nguoi van chuyen khong cong nhan hang hong, cho rang HangOK = TRUE

        }
    }

    function ThanhLyHopDong() payable public {
        
        // Kiem tra truong hop qua han moi duoc thanh ly
        require (block.timestamp > ThoiHanHopDong);

        // Chi cho cac ben tham gia thanh ly hop dong
        require( msg.sender == TaiKhoanNguoiMua || msg.sender == TaiKhoanNguoiBan || msg.sender == TaiKhoanVanChuyen );

        // Thanh ly hop dong chi moi dat coc ma chua lam gi
        if (TrangThaiHopDong == enTrangThaiHopDong.NguoiMuaDaDatCoc) {
            // Tra lai tien cho nguoi mua toan bo so tien trong CONTRACT 
            TaiKhoanNguoiMua.transfer( address(this).balance );
        } 

        // Thanh ly hop dong dang giao hang thi chim tau 
        if (TrangThaiHopDong == enTrangThaiHopDong.HangDangGiao) {
            // Tra lai tien cho nguoi mua va nguoi ban
            TaiKhoanNguoiBan.transfer( TienHang * (1 gwei) );
            TaiKhoanNguoiMua.transfer( address(this).balance );
        }

        // Thanh ly hop dong khi den noi thi nguoi mua "CHET" hoac khong nhan hang
        if (TrangThaiHopDong == enTrangThaiHopDong.HangDaToiDichRoi) {
            // Chia ra 2 truong hop, thanh ly ngay, hoac la mang hang ve tra lai NGUOI BAN
            // TRUONG HOP THANH LY NGAY vi den day nguoi ban va nguoi van chuyen da hoan thanh trach nhiem
            // Tra tien cho nguoi ban binh thuong
            TaiKhoanNguoiBan.transfer( TienHang * (1 gwei) );

            // Tra tien cho nguoi van chuyen binh thuong 
            TaiKhoanVanChuyen.transfer( (TienHang + TienVanChuyen) * (1 gwei) );

            // Vet not tien con du trong CONTRACT tra lai cho nguoi mua 
            TaiKhoanNguoiMua.transfer( address(this).balance );
        }

        // Thanh ly hop dong dang cho phan xu
        if (TrangThaiHopDong == enTrangThaiHopDong.ChoPhanXu) {
            // Tra lai tien cho nguoi mua va nguoi ban
            TaiKhoanNguoiBan.transfer( TienHang * (1 gwei) );
            TaiKhoanNguoiMua.transfer( address(this).balance );
        }

    }
}