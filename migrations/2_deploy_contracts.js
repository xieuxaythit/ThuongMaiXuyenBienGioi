var HopDongThuongMai = artifacts.require("HopDongThuongMai");

// var adNguoiMua          = "0x7edbF50d5a71408914a280768C1aE724dF43dAa6", 
//     adNguoiBan          = "0x0d8E1dd1C9BC92559F8317dfc50F2ADD080D3f24", 
//     intTienHang         = 100000000000, 
//     intTienVanChuyen    = 10000000000;

module.exports = deployer => {
    deployer.deploy(HopDongThuongMai);
};