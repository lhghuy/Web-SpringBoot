package com.example.FoodHKD.rest.admin;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.example.FoodHKD.model.ReportDTO;
import com.example.FoodHKD.service.ReportService;

@RestController
@RequestMapping("/api/admin/reports")
public class ReportRest {

    @Autowired
    private ReportService reportService;

    @GetMapping
    public ResponseEntity<Map<String, Object>> getReport(
            @RequestParam String dateFrom,
            @RequestParam String dateTo) {
        try {
       
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
            LocalDate startDate;
            LocalDate endDate;

            try {
                startDate = LocalDate.parse(dateFrom, formatter);
                endDate = LocalDate.parse(dateTo, formatter);
            } catch (DateTimeParseException e) {
                Map<String, Object> response = new HashMap<>();
                response.put("success", false);
                response.put("message", "Định dạng ngày không hợp lệ. Vui lòng sử dụng định dạng yyyy-MM-dd");
                return ResponseEntity.badRequest().body(response);
            }

     
            if (startDate.isAfter(endDate)) {
                Map<String, Object> response = new HashMap<>();
                response.put("success", false);
                response.put("message", "Ngày bắt đầu không được sau ngày kết thúc");
                return ResponseEntity.badRequest().body(response);
            }

           
            LocalDate today = LocalDate.now();
            if (startDate.isAfter(today) || endDate.isAfter(today)) {
                Map<String, Object> response = new HashMap<>();
                response.put("success", false);
                response.put("message", "Không thể tạo báo cáo cho ngày trong tương lai");
                return ResponseEntity.badRequest().body(response);
            }

      
            ReportDTO report = reportService.getReport(startDate, endDate);

            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Báo cáo được tạo thành công");
            response.put("data", report);

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "Lỗi khi tạo báo cáo: " + e.getMessage());
            return ResponseEntity.internalServerError().body(response);
        }
    }

    

}
