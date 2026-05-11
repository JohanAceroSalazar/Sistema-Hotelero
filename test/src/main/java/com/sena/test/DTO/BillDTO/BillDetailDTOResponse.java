package com.sena.test.DTO.BillDTO;

    import lombok.Getter;
    import lombok.Setter;

    @Getter
    @Setter

public class BillDetailDTOResponse {

    private Long id;
    private Integer quantity;
    private Double price ;
    private String productName;

}
